// API types matching NestJS backend response shapes

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message: string;
}

export interface ApiError {
  success: false;
  error: string;
  message: string;
}

export interface PaginatedData<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

// ─── User ────────────────────────────────────────────────────────────────────

export interface User {
  id: number;
  firebaseUid: string;
  name: string;
  email: string | null;
  photoUrl: string | null;
  coins: number;
  lives: number;
  xp: number;
  level: number;
  isBanned: boolean;
  isGuest: boolean;
  countryCode: string | null;
  appLanguage: string;
  createdAt: string;
  updatedAt: string;
}

// ─── Question ────────────────────────────────────────────────────────────────

export interface Question {
  id: number;
  questionText: string;
  options: string[];
  correctAnswer: string;
  explanation: string | null;
  difficultyLevel: 'easy' | 'medium' | 'hard';
  categoryId: number;
  category?: Category;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

// ─── Category ────────────────────────────────────────────────────────────────

export interface Category {
  id: number;
  name: string;
  description: string | null;
  iconUrl: string | null;
  colorHex: string | null;
  sortOrder: number;
  isActive: boolean;
  questionCount?: number;
  createdAt: string;
  updatedAt: string;
}

// ─── Contest ─────────────────────────────────────────────────────────────────

export interface Contest {
  id: number;
  title: string;
  description: string | null;
  startTime: string;
  endTime: string;
  entryFee: number;
  prizePool: number;
  maxParticipants: number | null;
  participantCount: number;
  status: 'draft' | 'active' | 'ended' | 'cancelled';
  createdAt: string;
  updatedAt: string;
}

// ─── League ──────────────────────────────────────────────────────────────────

export interface League {
  id: number;
  name: string;
  tier: number;
  minXp: number;
  maxXp: number | null;
  iconUrl: string | null;
  colorHex: string | null;
  memberCount: number;
  createdAt: string;
  updatedAt: string;
}

// ─── Sponsor / Ad ────────────────────────────────────────────────────────────

export interface Sponsor {
  id: number;
  name: string;
  logoUrl: string | null;
  websiteUrl: string | null;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

// ─── Stats ───────────────────────────────────────────────────────────────────

export interface DashboardStats {
  totalUsers: number;
  totalQuestions: number;
  activeLeagues: number;
  unresolvedFraud: number;
  successfulPaymentsToday: number;
}

// ─── Notification ────────────────────────────────────────────────────────────

export interface NotificationPayload {
  title: string;
  body: string;
  targetGroup: 'all' | 'active' | 'inactive';
  data?: Record<string, string>;
}
