/**
 * Partner-specific API client.
 * Uses the partner's Firebase ID token (exchanged from a custom token with
 * partner claims), stored in the NextAuth session under `partnerToken`.
 */
import axios from 'axios';
import { getSession, signOut } from 'next-auth/react';
import { toast } from 'sonner';
import type { ApiResponse } from '@/types/api';

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3000';

export const partnerApiClient = axios.create({
  baseURL: API_URL,
  headers: { 'Content-Type': 'application/json' },
});

partnerApiClient.interceptors.request.use(async (config) => {
  const session = await getSession();
  // @ts-expect-error — extended session type
  const token: string | undefined = session?.partnerToken ?? session?.firebaseToken;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

partnerApiClient.interceptors.response.use(
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
  (error: { response?: { status: number; data?: { message?: string } }; message?: string }) => {
    if (error.response?.status === 401) {
      toast.error('Partner session expired. Please sign in again.');
      void signOut({ callbackUrl: '/partner/auth/login' });
      return Promise.reject(new Error('Session expired'));
    }
    const message = error.response?.data?.message ?? error.message ?? 'Network error';
    return Promise.reject(new Error(message));
  },
);

// ─── Partner API helper methods ──────────────────────────────────────────────

export const partnerApi = {
  // Profile
  getProfile: () => partnerApiClient.get('/v2/partner/profile').then((r) => r.data),
  updateProfile: (data: object) => partnerApiClient.put('/v2/partner/profile', data).then((r) => r.data),

  // Team
  listTeam: () => partnerApiClient.get('/v2/partner/team').then((r) => r.data),
  inviteTeamMember: (email: string, role: string) =>
    partnerApiClient.post('/v2/partner/team/invite', { email, role }).then((r) => r.data),
  removeTeamMember: (memberId: number) =>
    partnerApiClient.delete(`/v2/partner/team/${memberId}`).then((r) => r.data),

  // Contests
  listContests: (params?: { status?: string; page?: number; limit?: number }) =>
    partnerApiClient.get('/v2/partner/contests', { params }).then((r) => r.data),
  getContest: (id: number) => partnerApiClient.get(`/v2/partner/contests/${id}`).then((r) => r.data),
  createContest: (data: object) => partnerApiClient.post('/v2/partner/contests', data).then((r) => r.data),
  updateContest: (id: number, data: object) =>
    partnerApiClient.put(`/v2/partner/contests/${id}`, data).then((r) => r.data),
  publishContest: (id: number) =>
    partnerApiClient.post(`/v2/partner/contests/${id}/publish`).then((r) => r.data),
  endContest: (id: number) =>
    partnerApiClient.post(`/v2/partner/contests/${id}/end`).then((r) => r.data),
  deleteContest: (id: number) =>
    partnerApiClient.delete(`/v2/partner/contests/${id}`).then((r) => r.data),
  regenerateCode: (id: number) =>
    partnerApiClient.post(`/v2/partner/contests/${id}/regenerate-code`).then((r) => r.data),

  // Questions
  listQuestions: (contestId: number) =>
    partnerApiClient.get(`/v2/partner/contests/${contestId}/questions`).then((r) => r.data),
  addQuestion: (contestId: number, data: object) =>
    partnerApiClient.post(`/v2/partner/contests/${contestId}/questions`, data).then((r) => r.data),
  updateQuestion: (contestId: number, qid: number, data: object) =>
    partnerApiClient.put(`/v2/partner/contests/${contestId}/questions/${qid}`, data).then((r) => r.data),
  deleteQuestion: (contestId: number, qid: number) =>
    partnerApiClient.delete(`/v2/partner/contests/${contestId}/questions/${qid}`).then((r) => r.data),
  addFromBank: (contestId: number, questionIds: number[]) =>
    partnerApiClient
      .post(`/v2/partner/contests/${contestId}/questions/from-bank`, { questionIds })
      .then((r) => r.data),
  reorderQuestions: (contestId: number, orderedIds: number[]) =>
    partnerApiClient
      .put(`/v2/partner/contests/${contestId}/questions/reorder`, { orderedIds })
      .then((r) => r.data),

  // Participants
  listParticipants: (contestId: number, params?: { submitted?: boolean; page?: number; limit?: number }) =>
    partnerApiClient.get(`/v2/partner/contests/${contestId}/participants`, { params }).then((r) => r.data),
  getLeaderboard: (contestId: number) =>
    partnerApiClient.get(`/v2/partner/contests/${contestId}/leaderboard`).then((r) => r.data),
  distributePrizes: (contestId: number) =>
    partnerApiClient.post(`/v2/partner/contests/${contestId}/prizes/distribute`).then((r) => r.data),

  // Analytics
  getAnalytics: () => partnerApiClient.get('/v2/partner/analytics').then((r) => r.data),
  getContestAnalytics: (contestId: number) =>
    partnerApiClient.get(`/v2/partner/analytics/contests/${contestId}`).then((r) => r.data),
};

export default partnerApiClient;
