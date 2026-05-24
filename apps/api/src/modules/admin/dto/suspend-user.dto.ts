import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export enum SuspendAction {
  SUSPEND = 'suspend',
  UNSUSPEND = 'unsuspend',
}

export class SuspendUserDto {
  @ApiProperty({ enum: SuspendAction })
  @IsEnum(SuspendAction)
  action!: SuspendAction;

  @ApiPropertyOptional({ description: 'Reason for suspension (stored in admin audit log)' })
  @IsOptional()
  @IsString()
  @MaxLength(512)
  reason?: string;
}
