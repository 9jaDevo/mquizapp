import type { NextConfig } from "next";

const securityHeaders = [
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
  {
    key: 'Permissions-Policy',
    value: 'camera=(), microphone=(), geolocation=()',
  },
  {
    key: 'Strict-Transport-Security',
    value: 'max-age=31536000; includeSubDomains',
  },
  {
    key: 'Content-Security-Policy',
    value: [
      "default-src 'self'",
      // 'unsafe-inline' required for Next.js App Router hydration scripts
      "script-src 'self' 'unsafe-inline' https://accounts.google.com https://apis.google.com",
      "frame-src https://accounts.google.com",
      [
        "connect-src 'self'",
        'https://identitytoolkit.googleapis.com',
        'https://securetoken.googleapis.com',
        'https://www.googleapis.com',
        // Allow configured API (set NEXT_PUBLIC_API_URL in env)
        process.env.NEXT_PUBLIC_API_URL ?? '',
      ].filter(Boolean).join(' '),
      "img-src 'self' data: https:",
      "style-src 'self' 'unsafe-inline'",
    ].join('; '),
  },
];

const nextConfig: NextConfig = {
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: securityHeaders,
      },
    ];
  },
};

export default nextConfig;
