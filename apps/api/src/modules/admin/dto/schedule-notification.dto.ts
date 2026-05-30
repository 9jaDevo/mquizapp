import { Type } from 'class-transformer';
import { IsDateString, IsInt, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ScheduleNotificationDto {
  @ApiProperty({ description: 'Notification title' })
  @IsString()
  @MinLength(1)
  @MaxLength(128)
  title: string;

  @ApiProperty({ description: 'Notification body text' })
  @IsString()
  @MinLength(1)
  @MaxLength(2000)
  message: string;

  @ApiPropertyOptional({ type: [Number], description: 'Target user IDs; omit for broadcast' })
  @IsOptional()
  @IsInt({ each: true })
  @Type(() => Number)
  userIds?: number[];

  @ApiPropertyOptional({ default: 'general' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  type?: string;

  @ApiPropertyOptional({ default: 0 })
  @IsOptional()
  @IsInt()
  @Type(() => Number)
  typeId?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(128)
  image?: string;

  @ApiProperty({ description: 'ISO 8601 datetime when to send, must be in the future' })
  @IsDateString()
  sendAt: string;
}
