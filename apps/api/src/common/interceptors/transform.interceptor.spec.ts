import { lastValueFrom, of } from 'rxjs';
import { CallHandler, ExecutionContext } from '@nestjs/common';
import { TransformInterceptor } from './transform.interceptor';

describe('TransformInterceptor', () => {
  const interceptor = new TransformInterceptor<unknown>();
  const ctx = {} as ExecutionContext;
  const buildHandler = (value: unknown): CallHandler => ({ handle: () => of(value) });

  it('wraps plain payloads in the standard envelope', async () => {
    const out = await lastValueFrom(interceptor.intercept(ctx, buildHandler({ foo: 1 })));
    expect(out).toEqual({ success: true, data: { foo: 1 }, message: 'OK' });
  });

  it('wraps primitives', async () => {
    const out = await lastValueFrom(interceptor.intercept(ctx, buildHandler('hello')));
    expect(out).toEqual({ success: true, data: 'hello', message: 'OK' });
  });

  it('respects pre-wrapped responses (with success boolean)', async () => {
    const pre = { success: true, data: { x: 1 }, message: 'Custom' };
    const out = await lastValueFrom(interceptor.intercept(ctx, buildHandler(pre)));
    expect(out).toBe(pre);
  });

  it('wraps null payloads', async () => {
    const out = await lastValueFrom(interceptor.intercept(ctx, buildHandler(null)));
    expect(out).toEqual({ success: true, data: null, message: 'OK' });
  });
});
