`<script lang="ts">
  import { nhost } from '../nhost';
  import { authStore } from './AuthStore';
  
  let email = '';
  let password = '';
  let loading = false;
  let error = '';

  async function handleLogin() {
    loading = true;
    error = '';
    
    try {
      const { session, error: loginError } = await nhost.auth.signIn({
        email,
        password
      });

      if (loginError) {
        throw loginError;
      }
    } catch (e) {
      error = e.message;
    } finally {
      loading = false;
    }
  }

  async function handleSignup() {
    loading = true;
    error = '';
    
    try {
      const { session, error: signupError } = await nhost.auth.signUp({
        email,
        password
      });

      if (signupError) {
        throw signupError;
      }
    } catch (e) {
      error = e.message;
    } finally {
      loading = false;
    }
  }
</script>

<div class="min-h-screen flex items-center justify-center">
  <div class="glass p-8 w-full max-w-md">
    <h2 class="text-2xl text-white font-bold mb-6 text-center">Welcome</h2>
    
    <form class="space-y-4" on:submit|preventDefault={handleLogin}>
      {#if error}
        <div class="bg-red-500/20 border border-red-500/50 text-red-200 p-3 rounded">
          {error}
        </div>
      {/if}
      
      <div>
        <label class="block text-white mb-2" for="email">Email</label>
        <input
          id="email"
          type="email"
          bind:value={email}
          class="w-full p-2 rounded bg-white/10 border border-white/20 text-white focus:ring-2 focus:ring-blue-500 transition-all"
          required
        />
      </div>
      
      <div>
        <label class="block text-white mb-2" for="password">Password</label>
        <input
          id="password"
          type="password"
          bind:value={password}
          class="w-full p-2 rounded bg-white/10 border border-white/20 text-white focus:ring-2 focus:ring-blue-500 transition-all"
          required
        />
      </div>
      
      <div class="flex gap-4">
        <button
          type="submit"
          class="flex-1 px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors duration-200 disabled:opacity-50"
          disabled={loading}
        >
          {loading ? 'Processing...' : 'Login'}
        </button>
        
        <button
          type="button"
          on:click={handleSignup}
          class="flex-1 px-6 py-2 bg-white/10 text-white rounded hover:bg-white/20 transition-colors duration-200 disabled:opacity-50"
          disabled={loading}
        >
          Sign Up
        </button>
      </div>
    </form>
  </div>
</div>`