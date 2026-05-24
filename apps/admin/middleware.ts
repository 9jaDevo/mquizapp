import { withAuth } from 'next-auth/middleware';
import { NextResponse } from 'next/server';

export default withAuth(
  function middleware(req) {
    const token = req.nextauth.token;

    // Block non-admins from all protected routes
    if (token && !token.isAdmin) {
      return NextResponse.redirect(new URL('/unauthorized', req.url));
    }

    return NextResponse.next();
  },
  {
    callbacks: {
      authorized: ({ token }) => !!token,
    },
  },
);

export const config = {
  // Protect everything except auth routes, static assets, and api/auth
  matcher: [
    '/((?!login|unauthorized|api/auth|_next/static|_next/image|favicon.ico).*)',
  ],
};
