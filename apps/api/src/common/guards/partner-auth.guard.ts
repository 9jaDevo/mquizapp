import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';

@Injectable()
export class PartnerAuthGuard implements CanActivate {
  private readonly logger = new Logger(PartnerAuthGuard.name);

  constructor(private readonly firebase: FirebaseService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
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

    let decoded: Awaited<ReturnType<FirebaseService['verifyIdToken']>>;
    try {
      decoded = await this.firebase.verifyIdToken(token);
    } catch (err) {
      this.logger.warn(`Partner token verification failed: ${(err as Error).message}`);
      throw new UnauthorizedException({
        error: 'AUTH_INVALID_TOKEN',
        message: 'Firebase token is invalid or expired',
      });
    }

    // Token must carry partner claims issued by our login endpoint
    if (!decoded.partnerId || !decoded.partnerRole) {
      throw new ForbiddenException({
        error: 'NOT_A_PARTNER_TOKEN',
        message: 'This token does not carry partner claims',
      });
    }

    // Status check is enforced in the service layer (after DB lookup) but we
    // can surface a clear message here by checking the claim
    if (decoded.partnerStatus === 'suspended') {
      throw new ForbiddenException({
        error: 'PARTNER_SUSPENDED',
        message: 'This partner account has been suspended',
      });
    }

    request.partner = {
      partnerId: decoded.partnerId as number,
      partnerRole: decoded.partnerRole as string,
      firebaseUid: decoded.uid,
    };
    return true;
  }
}
