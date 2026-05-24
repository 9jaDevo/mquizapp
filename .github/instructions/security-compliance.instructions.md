---
description: "Use when reviewing code for security issues, implementing authentication, handling payments, validating inputs, or any code that touches user data, money, or external APIs. Covers OWASP Top 10, Firebase auth, Paystack webhooks, rate limiting, and injection prevention."
---

# Security Compliance Rules

These rules apply to all layers: NestJS API, Next.js admin, and Flutter app.

## OWASP Top 10 — Platform-Specific Mitigations

### A01 — Broken Access Control
- Every NestJS endpoint requires explicit `@UseGuards(FirebaseAuthGuard)` or an explicit `@Public()` decorator.
- Never use a user ID from request body or query string to identify the acting user — always use `user.uid` from the verified Firebase token.
- Admin endpoints additionally require `@UseGuards(FirebaseAuthGuard, RolesGuard)` + `@Roles('admin')`.
- Ownership checks: when a user accesses their own resource (e.g., `GET /v2/users/:id`), verify `id` resolves to the authenticated user. Do not allow access to other users' private data.

### A02 — Cryptographic Failures
- Never store passwords — Firebase Auth handles authentication.
- Never log Firebase tokens, API keys, or payment references in plaintext logs.
- Paystack webhook signature must be verified with HMAC-SHA512 before processing:

```typescript
import * as crypto from 'crypto';

function verifyPaystackSignature(body: string, signature: string): boolean {
  const hash = crypto
    .createHmac('sha512', process.env.PAYSTACK_WEBHOOK_SECRET)
    .update(body)
    .digest('hex');
  return hash === signature;
}
```

### A03 — Injection
- All DB access goes through Prisma — parameterized queries are automatic. Never use `prisma.$queryRawUnsafe()` with user-controlled input.
- For any raw SQL fragment (e.g., `prisma.$queryRaw`), use tagged template literals (`Prisma.sql`) — not string concatenation.
- Sanitize user-generated content (question text, names, comments) before storing — strip HTML tags at minimum.

### A04 — Insecure Design
- Lives-restore and coin-award endpoints must be server-side only — the client sends intent; the server validates and applies the change.
- Daily streak check-in must be idempotent — calling it twice in a day must be safe.
- Quiz submit endpoint must check that the quiz session is still valid before awarding coins.

### A05 — Security Misconfiguration
- CORS must explicitly whitelist app origins (`mquiz.uk`, `admin.mquiz.uk`, app bundle IDs). Do not use `origin: '*'` in production.
- All environment variables must be validated at startup — if `FIREBASE_PRIVATE_KEY` is missing, the app must not start.
- Remove the Swagger UI (`/v2/docs`) in production builds, or protect it with admin auth.

### A06 — Vulnerable Components
- Run `npm audit` before every release. Fix high/critical issues before deploying.
- Pin major versions in `package.json` — do not use `*` or `latest`.

### A07 — Identification and Authentication Failures
- Firebase token expiry is enforced by Firebase — do not cache tokens server-side for longer than their expiry.
- Guest sessions must be rate-limited aggressively — max 5 guest accounts per device ID per day.
- Suspicious login patterns (new device + high-score within 1 hour) must be flagged in `tbl_fraud_detection`.

### A08 — Software and Data Integrity Failures
- Payment fulfillment (coin award, subscription activation) must re-verify the transaction with the payment gateway before acting — never trust the webhook payload alone.
- AI-generated questions must be in `status = 0` (pending review) by default — never auto-publish AI content.

### A09 — Security Logging and Monitoring
- Log authentication failures (invalid token, suspended user) with user agent and IP at WARN level.
- Log all payment webhook events (success, failure, signature mismatch) at INFO/ERROR level.
- Log fraud detection triggers at WARN level.
- Never log full request bodies containing user answers or payment details.

### A10 — Server-Side Request Forgery (SSRF)
- The AI module makes outbound calls to OpenAI — only call the configured OpenAI base URL, never a URL provided by user input.
- Sponsor banner redirect URLs must be validated to start with `https://` before storing.

## Rate Limiting Configuration

Apply `@Throttle()` at these thresholds:

| Endpoint group | Limit | Window |
|---|---|---|
| Auth (`/v2/auth/*`) | 10 requests | 60 seconds |
| AI explanations (`/v2/ai/explain-answer`) | 20 requests | 60 seconds |
| AI generation (`/v2/ai/generate-questions`) | 5 requests | 60 seconds |
| Payment init (`/v2/payments/*`) | 10 requests | 60 seconds |
| Quiz submit (`/v2/quiz/submit`) | 30 requests | 60 seconds |
| Public config (`/v2/config/*`) | 60 requests | 60 seconds |

## Flutter Security

- Never hardcode API base URLs, ad unit IDs, or Firebase configs in Dart code — load from environment or remote config.
- Obfuscate the release build: `flutter build apk --obfuscate --split-debug-info=...`
- Certificate pinning is recommended for the Dio client in production.
- Referral codes and promo codes must be validated server-side — the Flutter app only submits them.

## Fraud Prevention

The `tbl_fraud_detection` table must be written to when:
- A user submits a quiz in under 2 seconds per question (quiz_speed)
- Multiple accounts are registered from the same device within 24 hours (multi_account)
- Ad reward claims exceed 10 per hour (ad_spam)
- Coin balance changes without a matching transaction record (instant_withdraw)
