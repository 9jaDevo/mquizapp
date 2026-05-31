import { ExecutionContext, createParamDecorator } from '@nestjs/common';

export interface PartnerPrincipal {
  partnerId: number;
  partnerRole: string;
  firebaseUid: string;
}

export const CurrentPartner = createParamDecorator(
  (data: keyof PartnerPrincipal | undefined, ctx: ExecutionContext): PartnerPrincipal | unknown => {
    const request = ctx.switchToHttp().getRequest();
    const partner: PartnerPrincipal | undefined = request.partner;
    if (!partner) return undefined;
    return data ? partner[data] : partner;
  },
);
