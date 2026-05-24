---
description: "Run a security audit on a specific file or feature. Checks for OWASP Top 10 issues specific to the mQuiz platform: broken auth, missing input validation, Paystack webhook integrity, SQL injection via raw Prisma, SSRF, and fraud bypass risks."
---

Perform a security audit on the following file or feature: **${input:targetFile}**

## Audit Checklist

Work through each section. For each issue found, report:
- **File and line reference**
- **Issue type** (OWASP category)
- **Severity** (Critical / High / Medium / Low)
- **Recommended fix** (with code example)

### 1. Authentication & Authorization (OWASP A01, A07)

- [ ] Is every non-public endpoint protected by `FirebaseAuthGuard`?
- [ ] Is user identity ONLY derived from `@CurrentUser()` (verified token), never from request body/query?
- [ ] Do admin endpoints use `RolesGuard` + `@Roles()`?
- [ ] Are there any endpoints that access another user's private data without an ownership check?
- [ ] In Flutter: is every API call going through the Dio client that auto-attaches the Firebase token?

### 2. Input Validation (OWASP A03)

- [ ] Does every `@Body()` and `@Query()` parameter have a DTO with `class-validator` decorators?
- [ ] Is `ValidationPipe` configured with `whitelist: true, forbidNonWhitelisted: true`?
- [ ] Are there any `parseInt`, `parseFloat`, or direct casts without validation?
- [ ] Is user-generated text (question text, names, comments) sanitized before storage?

### 3. Database Security (OWASP A03)

- [ ] Are there any `prisma.$queryRawUnsafe()` calls with user-controlled input?
- [ ] Are any `prisma.$queryRaw` calls using string concatenation instead of `Prisma.sql` tagged templates?
- [ ] Do list queries have pagination (`take` limits) to prevent data dumps?
- [ ] Are sensitive fields excluded from responses via `select`?

### 4. Payment & Webhook Integrity (OWASP A08)

- [ ] Does the Paystack webhook handler verify the `x-paystack-signature` header with HMAC-SHA512 BEFORE processing the event?
- [ ] Is the payment re-verified with the Paystack API before fulfilling coins or subscriptions?
- [ ] Is the payment reference stored and checked for duplicate processing (idempotency)?

### 5. Cryptographic & Secret Handling (OWASP A02)

- [ ] Are there any hardcoded API keys, secrets, or tokens?
- [ ] Are Firebase tokens, payment references, or raw bodies logged anywhere?
- [ ] Are environment variables validated at startup (`ConfigService` required fields)?

### 6. Rate Limiting & Abuse Prevention (OWASP A04)

- [ ] Are auth endpoints rate-limited?
- [ ] Are AI generation endpoints rate-limited (max 5 req/min)?
- [ ] Are quiz-submit endpoints protected against speed exploits (< 2 sec per question)?
- [ ] Are rewarded-ad restore endpoints protected against ad spam (max 10/hr)?

### 7. SSRF & External Calls (OWASP A10)

- [ ] Does any endpoint accept a URL from user input and make an outbound HTTP call to it?
- [ ] Is the OpenAI API URL hardcoded or from a trusted env variable — NOT from user input?
- [ ] Are sponsor redirect URLs validated to start with `https://` before storage?

### 8. Fraud & Game Integrity

- [ ] Is coins awarding done server-side only?
- [ ] Can the client manipulate the score submitted to the quiz submit endpoint?
- [ ] Is there a check that prevents the same daily quiz being submitted twice?
- [ ] Are new devices getting high scores flagged in `tbl_fraud_detection`?

## Output Format

For each finding:

```
SEVERITY: Critical
FILE: apps/api/src/modules/payments/payments.service.ts:45
ISSUE: Webhook fulfills coins without verifying Paystack signature
OWASP: A08 — Software and Data Integrity Failures
FIX:
  const isValid = verifyPaystackSignature(rawBody, req.headers['x-paystack-signature']);
  if (!isValid) throw new UnauthorizedException('Invalid webhook signature');
```

If no issues are found in a section, state: "✅ Section clean."
