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
  category: number;
  subcategory: number;
  languageId: number;
  image: string;
  question: string;
  questionType: number;
  optiona: string;
  optionb: string;
  optionc: string;
  optiond: string;
  optione?: string | null;
  answer: string;
  level: number;
  note: string;
}

// ─── Category ────────────────────────────────────────────────────────────────

export interface Category {
  id: number;
  name: string;
  slug?: string | null;
  type?: number;
  isPremium?: number;
  coins?: number;
  image?: string | null;
  rowOrder?: number;
  languageId?: number;
  description?: string | null;
  iconUrl?: string | null;
  colorHex?: string | null;
  sortOrder?: number;
  isActive?: boolean;
  questionCount?: number;
  createdAt?: string | null;
  updatedAt?: string | null;
}

// ─── Contest ─────────────────────────────────────────────────────────────────

export interface Contest {
  id: number;
  title: string;
  name?: string;
  description: string | null;
  image?: string | null;
  entry?: number;
  entryFee?: number;
  prizePool?: number;
  prizeStatus?: number;
  languageId?: number;
  startTime?: string;
  startDate: string;
  endTime?: string;
  endDate: string;
  maxParticipants?: number | null;
  participantCount?: number;
  status: 'draft' | 'active' | 'ended' | 'cancelled' | string;
  statusCode?: number;
  createdAt?: string;
  updatedAt?: string;
}

// ─── League ──────────────────────────────────────────────────────────────────

export interface League {
  id: number;
  name: string;
  description?: string | null;
  image?: string | null;
  entry?: number;
  languageId?: number;
  prizeStatus?: number;
  startDate?: string;
  endDate?: string;
  tier?: number;
  season?: number;
  status: 'active' | 'ended' | 'upcoming' | string;
  statusCode?: number;
  minXp?: number;
  maxXp?: number | null;
  iconUrl?: string | null;
  colorHex?: string | null;
  memberCount?: number;
  participantCount?: number;
  createdAt?: string;
  updatedAt?: string;
}

// ─── Sponsor / Ad ────────────────────────────────────────────────────────────

export interface Sponsor {
  id: number;
  name: string;
  sponsorName?: string;
  title?: string | null;
  logoUrl: string | null;
  imageUrl?: string | null;
  websiteUrl: string | null;
  redirectUrl?: string | null;
  redirectType?: string | null;
  contactEmail: string | null;
  impressionLimit?: number;
  impressionPeriod?: string | null;
  currentImpressions?: number;
  startDate?: string;
  endDate?: string;
  priority?: number;
  isActive: boolean;
  createdAt?: string | null;
  updatedAt?: string | null;
}

// ─── Stats ───────────────────────────────────────────────────────────────────

export interface RecentFraudItem {
  id: number;
  userId: number | null;
  detectionType: string;
  severity: string;
  reason: string | null;
  createdAt: string | null;
}

export interface DashboardStats {
  totalUsers: number;
  totalQuestions: number;
  activeLeagues: number;
  activeContests?: number;
  unresolvedFraud: number;
  successfulPaymentsToday: number;
  paymentsToday: number;
  pendingAiQuestions?: number;
  dau?: number;
  mau?: number;
  recentFraud?: RecentFraudItem[];
}

export interface TimeSeriesPoint {
  date: string;
  count: number;
}

export interface RevenueSeriesPoint {
  date: string;
  total: number;
  count: number;
}

export interface CategoryStat {
  categoryId: number;
  name: string;
  questionCount: number;
}

export interface CountryStat {
  country: string;
  count: number;
}

export interface BadgeStat {
  key: string;
  label: string;
  earned: boolean;
  counter: number;
}

export interface UserBadgesResponse {
  userId: number;
  badges: BadgeStat[];
}

export interface FraudFlag {
  id: number;
  userId: number | null;
  reason: string | null;
  detection_type?: string | null;
  detectionType?: string | null;
  severity?: string | null;
  resolved?: number;
  metadata?: string | null;
  createdAt?: string | null;
}


// ─── Notification ────────────────────────────────────────────────────────────

export interface NotificationPayload {
  title: string;
  body: string;
  targetGroup: 'all' | 'active' | 'inactive';
  data?: Record<string, string>;
}

export interface NotificationHistoryItem {
  id: number;
  title: string;
  message: string;
  type: string;
  typeId: number;
  image: string;
  audience: string;
  userIds: string | null;
  dateSent: string;
}

// ─── Coin History ─────────────────────────────────────────────────────────────

export interface CoinHistoryItem {
  id: number;
  points: number;
  type: string;
  status: number;
  date: string | null;
}

// ─── Subcategory ──────────────────────────────────────────────────────────────

export interface Subcategory {
  id: number;
  maincatId: number;
  name: string;
  slug?: string | null;
  isPremium?: number;
  status?: number;
  coins?: number;
  image?: string | null;
  rowOrder?: number;
  languageId?: number;
}

// ─── Settings ────────────────────────────────────────────────────────────────

export interface SettingRow {
  id: number;
  type: string;
  message: string;
}
