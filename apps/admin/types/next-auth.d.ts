import 'next-auth';
import 'next-auth/jwt';

declare module 'next-auth' {
  interface Session {
    firebaseToken?: string;
    firebaseTokenExpiry?: number;
    user: {
      id: string;
      name?: string | null;
      email?: string | null;
      image?: string | null;
      isAdmin: boolean;
      role?: string;
    };
  }

  interface User {
    id: string;
    name?: string | null;
    email?: string | null;
    image?: string | null;
    isAdmin: boolean;
    role?: string;
    permissions?: string;
    firebaseToken?: string;
    firebaseTokenExpiry?: number;
  }
}

declare module 'next-auth/jwt' {
  interface JWT {
    firebaseToken?: string;
    firebaseTokenExpiry?: number;
    isAdmin: boolean;
    userId: string;
    role?: string;
    permissions?: string;
  }
}
