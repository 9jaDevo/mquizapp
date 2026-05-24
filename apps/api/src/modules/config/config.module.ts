import { Module } from '@nestjs/common';
import { ConfigDataController } from './config.controller';
import { ConfigDataService } from './config.service';

@Module({
  controllers: [ConfigDataController],
  providers: [ConfigDataService],
  exports: [ConfigDataService],
})
export class ConfigDataModule {}
