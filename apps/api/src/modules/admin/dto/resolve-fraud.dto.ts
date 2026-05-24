import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class ResolveFraudDto {
  @ApiPropertyOptional({ enum: ['none', 'review', 'warning', 'suspend'] })
  @IsOptional()
  @IsIn(['none', 'review', 'warning', 'suspend'])
  action?: 'none' | 'review' | 'warning' | 'suspend';

  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(500) notes?: string;
}
