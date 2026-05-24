import { Module } from '@nestjs/common';
import { BoostersController } from './boosters.controller';
import { BoostersService } from './boosters.service';

@Module({
  controllers: [BoostersController],
  providers: [BoostersService],
  exports: [BoostersService],
})
export class BoostersModule {}
