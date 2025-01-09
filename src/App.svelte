`<script lang="ts">
  import { authStore } from './lib/auth/AuthStore';
  import VideoAnalysis from './lib/VideoAnalysis.svelte';
  import Login from './lib/auth/Login.svelte';
</script>

<main>
  {#if $authStore.loading}
    <div class="min-h-screen flex items-center justify-center">
      <div class="animate-pulse-slow w-16 h-16 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
    </div>
  {:else if $authStore.isAuthenticated}
    <VideoAnalysis />
  {:else}
    <Login />
  {/if}
</main>`