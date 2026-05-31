import { Module } from '@nestjs/common';
import { PartnerAuthController } from './partner-auth.controller';
import { PartnerController } from './partner.controller';
import { PartnerPublicController } from './partner-public.controller';
import { PartnerService } from './partner.service';

@Module({
  controllers: [PartnerAuthController, PartnerController, PartnerPublicController],
  providers: [PartnerService],
  exports: [PartnerService],
})
export class PartnerModule {}
