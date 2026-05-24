import { ExecutionContext, createParamDecorator } from '@nestjs/common';
import type { DecodedIdToken } from 'firebase-admin/auth';

export const CurrentUser = createParamDecorator(
  (data: keyof DecodedIdToken | undefined, ctx: ExecutionContext): DecodedIdToken | unknown => {
    const request = ctx.switchToHttp().getRequest();
    const user: DecodedIdToken | undefined = request.user;
    if (!user) return undefined;
    return data ? user[data] : user;
  },
);
