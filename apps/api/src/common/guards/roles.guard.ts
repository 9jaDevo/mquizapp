import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles || requiredRoles.length === 0) return true;

    const request = context.switchToHttp().getRequest();
    const user = request.user;
    if (!user) {
      throw new ForbiddenException({
        error: 'AUTH_REQUIRED',
        message: 'Authentication required before role check',
      });
    }

    const userRoles: string[] = [];
    if (typeof user.role === 'string') userRoles.push(user.role);
    if (user.admin === true) userRoles.push('admin');
    if (user.customClaims) {
      if (typeof user.customClaims.role === 'string') userRoles.push(user.customClaims.role);
      if (user.customClaims.admin === true) userRoles.push('admin');
    }

    const hasRole = requiredRoles.some((r) => userRoles.includes(r));
    if (!hasRole) {
      throw new ForbiddenException({
        error: 'FORBIDDEN_ROLE',
        message: `Requires one of: ${requiredRoles.join(', ')}`,
      });
    }
    return true;
  }
}
