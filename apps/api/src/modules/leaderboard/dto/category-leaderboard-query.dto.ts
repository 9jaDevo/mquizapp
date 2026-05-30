import { Type } from 'class-transformer';
import { IsInt, IsOptional, IsString, IsIn, Length, Max, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CategoryLeaderboardQueryDto {
  @ApiProperty({ enum: ['daily', 'weekly', 'monthly', 'alltime'], required: false })
  @IsOptional()
  @IsString()
  @IsIn(['daily', 'weekly', 'monthly', 'alltime'])
  period?: 'daily' | 'weekly' | 'monthly' | 'alltime';

  @ApiProperty({ required: false, minimum: 1, maximum: 200, default: 50 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(200)
  limit?: number;

  @ApiPropertyOptional({ description: 'ISO 3166-1 alpha-2 or alpha-3 country code filter' })
  @IsOptional()
  @IsString()
  @Length(2, 3)
  countryCode?: string;
}
