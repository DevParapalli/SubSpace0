<script>
    import { onMount } from 'svelte';
    import { nhost } from './nhost';
    import { authStore } from './auth/AuthStore';
    
    export let onVideoSelect;
    
    let history = [];
    let loading = true;
  
    async function fetchHistory() {
      if (!$authStore.user) return;
      // 
      try {
        const { data, error } = await nhost.graphql.request(`
          query GetVideoHistory($user_id: uuid!) {
            analyses(
              where: { _and: [{user_id: { _eq: $user_id }}, { status: { _neq: "failed"}}] }
              order_by: { created_at: desc }
            ) {
              id
              video_id
              custom_instructions
              title
              thumbnail
              channel
              created_at
              status
              summary
            }
          }
        `, {
          user_id: $authStore.user.id
        });
  
        if (data?.analyses) {
          history = data.analyses;
        }
      } catch (error) {
        console.error('Error fetching history:', error);
      } finally {
        loading = false;
      }
    }
  
    onMount(() => {
      fetchHistory();
    });
  </script>
  
  <div class="space-y-4">
    <div class="flex items-center gap-2 mb-4">
      <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 text-blue-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="12" cy="12" r="10"/>
        <path d="M12 6v6l4 2"/>
      </svg>
      <h2 class="text-xl font-semibold text-white">Previous Analyses</h2>
    </div>
    
    {#if loading}
      <div class="w-full h-32 flex items-center justify-center">
        <div class="animate-spin w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full" />
      </div>
    {:else}
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {#each history as video}
          <div 
            class="glass p-4 cursor-pointer hover:ring-2 hover:ring-blue-500 transition-all"
            on:click={() => onVideoSelect(video)}
          >
            <div class="aspect-video mb-3">
              <img
                src={video.thumbnail || 'placeholder-image.jpg'}
                alt={video.title}
                class="w-full h-full object-cover rounded"
              />
            </div>
            <h3 class="font-medium mb-1 text-white">{video.title || 'Untitled Video'}</h3>
            <p class="text-sm text-gray-300 mb-2">{video.channel}</p>
            <div class="flex items-center gap-2 text-sm text-gray-400">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polygon points="23 7 16 12 23 17 23 7"/>
                <rect x="1" y="5" width="15" height="14" rx="2" ry="2"/>
              </svg>
              <span>{video.video_id}</span>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>