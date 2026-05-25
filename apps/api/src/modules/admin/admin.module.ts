import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { AdminAuthController } from './admin-auth.controller';
import { AdminService } from './admin.service';

@Module({
  controllers: [AdminController, AdminAuthController],
  providers: [AdminService],
  exports: [AdminService],
})
export class AdminModule {}
