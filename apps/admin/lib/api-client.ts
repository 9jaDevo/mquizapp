import axios from 'axios';
import { getSession } from 'next-auth/react';
import type { ApiResponse } from '@/types/api';

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3000';

export const apiClient = axios.create({
  baseURL: API_URL,
  headers: { 'Content-Type': 'application/json' },
});

// Attach Firebase token from NextAuth session before every request
apiClient.interceptors.request.use(async (config) => {
  const session = await getSession();
  if (session?.firebaseToken) {
    config.headers.Authorization = `Bearer ${session.firebaseToken}`;
  }
  return config;
});

// Unwrap the { success, data, message } envelope
apiClient.interceptors.response.use(
  (response) => {
    const body: ApiResponse<unknown> = response.data;
    if (body && typeof body === 'object' && 'success' in body) {
      if (!body.success) {
        return Promise.reject(new Error(body.message ?? 'API error'));
      }
      response.data = body.data;
    }
    return response;
  },
  (error) => {
    const message =
      error.response?.data?.message ?? error.message ?? 'Network error';
    return Promise.reject(new Error(message));
  },
);

export default apiClient;
