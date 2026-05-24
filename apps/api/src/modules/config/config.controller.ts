import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ConfigDataService } from './config.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { Public } from '../../common/decorators/public.decorator';

@ApiTags('config')
@Controller({ path: 'config', version: '2' })
export class ConfigDataController {
  constructor(private readonly service: ConfigDataService) {}

  @Public()
  @Get()
  @ApiOperation({ summary: 'Get global app settings (cached)' })
  getAll() {
    return this.service.getAllSettings();
  }

  @Public()
  @Get('by-type')
  @ApiOperation({ summary: 'Get a single setting by type' })
  getByType(@Query('type') type: string) {
    return this.service.getByType(type);
  }
}
