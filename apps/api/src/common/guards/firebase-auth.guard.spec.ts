import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { FirebaseAuthGuard } from './firebase-auth.guard';
import { FirebaseService } from '../../firebase/firebase.service';

describe('FirebaseAuthGuard', () => {
  let guard: FirebaseAuthGuard;
  let firebase: jest.Mocked<Pick<FirebaseService, 'verifyIdToken'>>;
  let reflector: jest.Mocked<Pick<Reflector, 'getAllAndOverride'>>;

  const buildCtx = (headers: Record<string, string | undefined>): ExecutionContext => {
    const request = { headers, user: undefined };
    return {
      switchToHttp: () => ({ getRequest: () => request, getResponse: () => ({}), getNext: () => ({}) }),
      getHandler: () => () => undefined,
      getClass: () => class {},
    } as unknown as ExecutionContext;
  };

  beforeEach(() => {
    firebase = { verifyIdToken: jest.fn() };
    reflector = { getAllAndOverride: jest.fn().mockReturnValue(false) };
    guard = new FirebaseAuthGuard(firebase as unknown as FirebaseService, reflector as unknown as Reflector);
  });

  it('allows public routes without a token', async () => {
    reflector.getAllAndOverride.mockReturnValue(true);
    await expect(guard.canActivate(buildCtx({}))).resolves.toBe(true);
    expect(firebase.verifyIdToken).not.toHaveBeenCalled();
  });

  it('rejects when Authorization header is missing', async () => {
    await expect(guard.canActivate(buildCtx({}))).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('rejects when header is malformed (no Bearer prefix)', async () => {
    await expect(
      guard.canActivate(buildCtx({ authorization: 'invalidtoken' })),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('rejects when Firebase rejects the token', async () => {
    firebase.verifyIdToken.mockRejectedValueOnce(new Error('expired'));
    await expect(
      guard.canActivate(buildCtx({ authorization: 'Bearer bad.token' })),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('attaches decoded user to request on valid token', async () => {
    const ctx = buildCtx({ authorization: 'Bearer good.token' });
    firebase.verifyIdToken.mockResolvedValueOnce({ uid: 'uid-1', email: 'a@b.com' } as never);
    await expect(guard.canActivate(ctx)).resolves.toBe(true);
    const request = (ctx.switchToHttp().getRequest() as unknown) as { user: { uid: string } };
    expect(request.user.uid).toBe('uid-1');
  });
});
