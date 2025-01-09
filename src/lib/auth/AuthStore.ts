import { writable } from 'svelte/store';
import { nhost } from '../nhost';

export const authStore = writable({
  isAuthenticated: false,
  user: null,
  loading: true
});

// Initialize auth state from localStorage
const savedAuth = localStorage.getItem('auth');
if (savedAuth) {
  authStore.set(JSON.parse(savedAuth));
}

// Subscribe to auth state changes
nhost.auth.onAuthStateChanged((event, session) => {
  const authState = {
    isAuthenticated: !!session,
    user: session?.user || null,
    loading: false
  };
  
  authStore.set(authState);
  localStorage.setItem('auth', JSON.stringify(authState));
});