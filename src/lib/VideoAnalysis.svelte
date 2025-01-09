`<script lang="ts">
  import { onMount } from 'svelte';
  import { nhost } from './nhost';
  import { authStore } from './auth/AuthStore';
  
  let videoId = '';
  let customInstructions = '';
  let loading = false;
  let analysisId = '';

  // New state for API response
  let videoData = {
    summary: '',
    title: '',
    thumbnail: '',
    channel: ''
  };

  async function saveAnalysisState(status = 'in_progress') {
    if (!$authStore.user) return;

    const { data, error } = await nhost.graphql.request(`
      mutation SaveAnalysis($analysis: analyses_insert_input!) {
        insert_analyses_one(
          object: $analysis
          on_conflict: {
            constraint: analyses_pkey,
            update_columns: [status, custom_instructions, summary, title, thumbnail, channel]
          }
        ) {
          id
        }
      }
    `, {
      analysis: {
        id: analysisId || undefined,
        user_id: $authStore.user.id,
        video_id: videoId,
        custom_instructions: customInstructions,
        status,
        summary: videoData.summary,
        title: videoData.title,
        thumbnail: videoData.thumbnail,
        channel: videoData.channel
      }
    });

    if (data?.insert_analyses_one?.id) {
      analysisId = data.insert_analyses_one.id;
    }
  }

  async function handleSubmit() {
    if (!videoId) return;
    
    loading = true;
    try {
      // Save initial state
      await saveAnalysisState('in_progress');

      // Call the API
      const response = await fetch(`https://aiko-api.parapalli.dev/subspace/${videoId}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
        },
        // body: JSON.stringify({
        //   videoId,
        //   customInstructions
        // })
      });

      if (!response.ok) {
        throw new Error('Failed to analyze video');
      }

      videoData = await response.json();

      // Save completed state
      await saveAnalysisState('completed');
    } catch (error) {
      console.error('Error:', error);
      await saveAnalysisState('failed');
    } finally {
      loading = false;
    }
  }

  async function loadLastAnalysis() {
    if (!$authStore.user) return;

    const { data, error } = await nhost.graphql.request(`
      query GetLastAnalysis($user_id: uuid!) {
        analyses(
          where: { user_id: { _eq: $user_id } }
          order_by: { created_at: desc }
          limit: 1
        ) {
          id
          video_id
          custom_instructions
          summary
          title
          thumbnail
          channel
          status
        }
      }
    `, {
      user_id: $authStore.user.id
    });

    if (data?.analyses?.[0]) {
      const analysis = data.analyses[0];
      analysisId = analysis.id;
      videoId = analysis.video_id;
      customInstructions = analysis.custom_instructions;
      videoData = {
        summary: analysis.summary,
        title: analysis.title,
        thumbnail: analysis.thumbnail,
        channel: analysis.channel
      };
    }
  }

  onMount(() => {
    loadLastAnalysis();
  });
</script>

<div class="min-h-screen p-8">
  <div class="max-w-4xl mx-auto space-y-8">
    <!-- Input Section -->
    <div class="glass p-6">
      <form class="space-y-4" on:submit|preventDefault={handleSubmit}>
        <div>
          <label class="block text-white mb-2" for="customInstructions">Custom Instructions</label>
          <input
            id="customInstructions"
            type="text"
            bind:value={customInstructions}
            class="w-full p-2 rounded bg-white/10 border border-white/20 text-white focus:ring-2 focus:ring-blue-500 transition-all"
            placeholder="Optional instructions..."
          />
        </div>
        
        <div class="flex gap-4">
          <input
            type="text"
            bind:value={videoId}
            placeholder="Enter video ID"
            class="flex-1 p-2 rounded bg-white/10 border border-white/20 text-white focus:ring-2 focus:ring-blue-500 transition-all"
            required
          />
          <button
            type="submit"
            class="px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors duration-200 disabled:opacity-50"
            disabled={loading}
          >
            {loading ? 'Analyzing...' : 'Analyze'}
          </button>
        </div>
      </form>
    </div>

    <!-- Results Section -->
    {#if loading}
      <div class="glass p-6 flex items-center justify-center">
        <div class="animate-pulse-slow w-16 h-16 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
      </div>
    {:else if videoData.title}
      <div class="glass p-6 space-y-6">
        <div class="flex flex-col md:flex-row gap-6">
          <!-- Thumbnail -->
          <div class="md:w-1/3">
            <img
              src={videoData.thumbnail}
              alt={videoData.title}
              class="w-full rounded-lg shadow-lg"
            />
          </div>
          
          <!-- Info -->
          <div class="md:w-2/3 space-y-4">
            <h2 class="text-2xl font-bold text-white">{videoData.title}</h2>
            <p class="text-white/80">Channel: {videoData.channel}</p>
            
            <div class="glass p-4">
              <h3 class="text-lg font-semibold text-white mb-2">Summary</h3>
              <p class="text-white/90 leading-relaxed">{videoData.summary}</p>
            </div>
          </div>
        </div>
      </div>
    {/if}
  </div>
</div>`