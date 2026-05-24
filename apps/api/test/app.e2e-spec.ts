/**
 * E2E spec: Rate Limiting (throttle guard)
 *
 * Creates a minimal NestJS app with ThrottlerModule configured at 2 requests per minute,
 * then verifies the 3rd request returns HTTP 429 Too Many Requests.
 *
 * This validates the Phase 1 gate requirement:
 *   "Rate limiting tested: 429 returned after threshold"
 */
import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { Controller, Get, Module } from '@nestjs/common';
import request from 'supertest';

@Controller('test')
class TestController {
  @Get('ping')
  ping() {
    return { ok: true };
  }
}

@Module({
  imports: [
    ThrottlerModule.forRoot([{ ttl: 60_000, limit: 2 }]),
  ],
  controllers: [TestController],
  providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }],
})
class TestAppModule {}

describe('Rate Limiting (E2E)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [TestAppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('allows requests within the rate limit (first 2 succeed)', async () => {
    await request(app.getHttpServer()).get('/test/ping').expect(200);
    await request(app.getHttpServer()).get('/test/ping').expect(200);
  });

  it('returns 429 Too Many Requests when limit is exceeded', async () => {
    // 3rd request to same endpoint from same IP should be throttled
    await request(app.getHttpServer())
      .get('/test/ping')
      .expect(429);
  });
});
