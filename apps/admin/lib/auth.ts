import type { NextAuthOptions } from 'next-auth';
import GoogleProvider from 'next-auth/providers/google';
import CredentialsProvider from 'next-auth/providers/credentials';
import { initializeApp, getApps, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

// Initialize Firebase Admin SDK (singleton)
function getFirebaseAdmin() {
  if (getApps().length === 0) {
    const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
    if (!serviceAccountJson || serviceAccountJson === '{}') {
      console.warn('FIREBASE_SERVICE_ACCOUNT_JSON not set — admin auth will fail');
      return null;
    }
    try {
      const serviceAccount = JSON.parse(serviceAccountJson);
      initializeApp({ credential: cert(serviceAccount) });
    } catch (e) {
      console.error('Failed to parse FIREBASE_SERVICE_ACCOUNT_JSON', e);
      return null;
    }
  }
  return getAuth();
}

export const authOptions: NextAuthOptions = {
  providers: [
    // ── Primary: username + password against tbl_authenticate ───────────────
    CredentialsProvider({
      id: 'admin-db',
      name: 'Admin Credentials',
      credentials: {
        username: { label: 'Username', type: 'text' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        if (!credentials?.username || !credentials?.password) return null;

        const apiUrl = process.env.API_URL;
        if (!apiUrl) {
          console.error('API_URL not configured');
          return null;
        }

        try {
          const res = await fetch(`${apiUrl}/v2/admin/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              username: credentials.username,
              password: credentials.password,
            }),
          });

          if (!res.ok) return null;
          const body = await res.json() as {
            success?: boolean;
            data?: { id: number; username: string; role: string; permissions: string };
          };
          if (!body.success || !body.data) return null;

          const { id, username, role, permissions } = body.data;
          return {
            id: String(id),
            name: username,
            email: null,
            image: null,
            isAdmin: true,
            role,
            permissions,
          };
        } catch (err) {
          console.error('admin-db authorize error', err);
          return null;
        }
      },
    }),

    // ── Secondary: Google OAuth (requires admin Firebase custom claim) ───────
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID ?? '',
      clientSecret: process.env.GOOGLE_CLIENT_SECRET ?? '',
    }),

    // ── Dev/testing: raw Firebase ID token injection ──────────────────────
    CredentialsProvider({
      id: 'firebase-token',
      name: 'Firebase Token',
      credentials: {
        idToken: { label: 'Firebase ID Token', type: 'text' },
      },
      async authorize(credentials) {
        if (!credentials?.idToken) return null;
        const auth = getFirebaseAdmin();
        if (!auth) return null;

        try {
          const decoded = await auth.verifyIdToken(credentials.idToken);
          if (!decoded.admin) return null;

          return {
            id: decoded.uid,
            name: decoded.name ?? null,
            email: decoded.email ?? null,
            image: decoded.picture ?? null,
            isAdmin: true,
            role: 'admin',
            firebaseToken: credentials.idToken,
            firebaseTokenExpiry: (decoded.exp ?? 0) * 1000,
          };
        } catch {
          return null;
        }
      },
    }),
  ],

  callbacks: {
    async signIn({ user, account }) {
      // For Google OAuth, verify the admin Firebase custom claim
      if (account?.provider === 'google' && account.id_token) {
        const auth = getFirebaseAdmin();
        if (!auth) return false;
        try {
          const decoded = await auth.verifyIdToken(account.id_token);
          if (!decoded.admin) return '/unauthorized';
          (user as unknown as Record<string, unknown>).isAdmin = true;
          (user as unknown as Record<string, unknown>).role = 'admin';
          (user as unknown as Record<string, unknown>).firebaseToken = account.id_token;
          (user as unknown as Record<string, unknown>).firebaseTokenExpiry = (decoded.exp ?? 0) * 1000;
        } catch {
          return false;
        }
      }
      return true;
    },

    async jwt({ token, user }) {
      if (user) {
        token.userId = user.id;
        token.isAdmin = (user as { isAdmin?: boolean }).isAdmin ?? false;
        token.role = (user as { role?: string }).role ?? 'admin';
        token.permissions = (user as { permissions?: string }).permissions ?? '';
        token.firebaseToken = (user as { firebaseToken?: string }).firebaseToken ?? '';
        token.firebaseTokenExpiry = (user as { firebaseTokenExpiry?: number }).firebaseTokenExpiry ?? 0;
      }
      return token;
    },

    async session({ session, token }) {
      session.user.id = token.userId;
      session.user.isAdmin = token.isAdmin;
      session.user.role = token.role;
      session.firebaseToken = token.firebaseToken;
      session.firebaseTokenExpiry = token.firebaseTokenExpiry;
      return session;
    },
  },

  pages: {
    signIn: '/login',
    error: '/login',
  },

  session: {
    strategy: 'jwt',
    maxAge: 8 * 60 * 60, // 8 hours
  },

  cookies: {
    sessionToken: {
      name: `__Secure-next-auth.session-token`,
      options: {
        httpOnly: true,
        sameSite: 'lax',
        path: '/',
        secure: process.env.NODE_ENV === 'production',
      },
    },
  },
};
