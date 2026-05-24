import apiClient from '@/lib/api-client';

/**
 * Returns the pre-configured axios client with Firebase token interceptor.
 * Use this in client components for mutations (POST, PATCH, DELETE).
 */
export function useApiClient() {
  return apiClient;
}
