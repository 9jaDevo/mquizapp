import {
  CanActivate,
  ExecutionContext,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { FirebaseService } from '../../firebase/firebase.service';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  private readonly logger = new Logger(FirebaseAuthGuard.name);

  constructor(
    private readonly firebase: FirebaseService,
    private readonly reflector: Reflector,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const request = context.switchToHttp().getRequest();
    const authHeader: string | undefined = request.headers?.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException({
        error: 'AUTH_MISSING_TOKEN',
        message: 'Missing or malformed Authorization header',
      });
    }

    const token = authHeader.slice(7).trim();
    if (!token) {
      throw new UnauthorizedException({
        error: 'AUTH_MISSING_TOKEN',
        message: 'Bearer token is empty',
      });
    }

    try {
      const decoded = await this.firebase.verifyIdToken(token);
      request.user = decoded;
      return true;
    } catch (err) {
      this.logger.debug(`Token verification failed: ${(err as Error).message}`);
      throw new UnauthorizedException({
        error: 'AUTH_INVALID_TOKEN',
        message: 'Invalid or expired Firebase token',
      });
    }
  }
}
