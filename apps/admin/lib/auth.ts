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
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID ?? '',
      clientSecret: process.env.GOOGLE_CLIENT_SECRET ?? '',
    }),
    // Firebase token login for direct token injection (dev/testing)
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
          const isAdmin = decoded.admin === true;
          if (!isAdmin) return null;

          return {
            id: decoded.uid,
            name: decoded.name ?? null,
            email: decoded.email ?? null,
            image: decoded.picture ?? null,
            isAdmin: true,
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
      // For Google OAuth, verify the user has admin custom claim via Firebase
      if (account?.provider === 'google' && account.id_token) {
        const auth = getFirebaseAdmin();
        if (!auth) return false;
        try {
          const decoded = await auth.verifyIdToken(account.id_token);
          const isAdmin = decoded.admin === true;
          if (!isAdmin) return '/unauthorized';
          // Attach firebase token info to user object
          (user as Record<string, unknown>).isAdmin = true;
          (user as Record<string, unknown>).firebaseToken = account.id_token;
          (user as Record<string, unknown>).firebaseTokenExpiry = (decoded.exp ?? 0) * 1000;
        } catch {
          return false;
        }
      }
      return true;
    },

    async jwt({ token, user }) {
      // On first sign-in, copy user fields to token
      if (user) {
        token.userId = user.id;
        token.isAdmin = (user as { isAdmin?: boolean }).isAdmin ?? false;
        token.firebaseToken = (user as { firebaseToken?: string }).firebaseToken ?? '';
        token.firebaseTokenExpiry = (user as { firebaseTokenExpiry?: number }).firebaseTokenExpiry ?? 0;
      }
      return token;
    },

    async session({ session, token }) {
      session.user.id = token.userId;
      session.user.isAdmin = token.isAdmin;
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
