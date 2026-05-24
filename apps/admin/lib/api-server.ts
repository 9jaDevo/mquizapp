import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import type { ApiResponse } from '@/types/api';

/**
 * Server-side API client. Attaches the Firebase token from the session.
 * Use only in Server Components and Route Handlers.
 */
async function getAdminToken(): Promise<string> {
  const session = await getServerSession(authOptions);
  if (!session?.firebaseToken) {
    throw new Error('No session token');
  }
  return session.firebaseToken;
}

const API_URL = process.env.API_URL ?? 'http://localhost:3000';

async function apiFetch<T>(
  path: string,
  options: RequestInit & { next?: { tags?: string[]; revalidate?: number } } = {},
): Promise<T> {
  const token = await getAdminToken();
  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
      ...options.headers,
    },
    next: options.next,
  });

  if (!res.ok) {
    const errorBody = await res.json().catch(() => ({}));
    throw new Error(errorBody?.message ?? `HTTP ${res.status}`);
  }

  const json: ApiResponse<T> = await res.json();
  if (!json.success) {
    throw new Error(json.message ?? 'API error');
  }
  return json.data;
}

export const apiServer = {
  get: <T>(path: string, opts?: { tags?: string[]; revalidate?: number }) =>
    apiFetch<T>(path, { method: 'GET', next: opts }),

  post: <T>(path: string, body: unknown) =>
    apiFetch<T>(path, { method: 'POST', body: JSON.stringify(body) }),

  patch: <T>(path: string, body: unknown) =>
    apiFetch<T>(path, { method: 'PATCH', body: JSON.stringify(body) }),

  delete: <T>(path: string) => apiFetch<T>(path, { method: 'DELETE' }),
};
