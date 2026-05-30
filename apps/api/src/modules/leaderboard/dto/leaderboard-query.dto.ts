import { Type } from 'class-transformer';
import { IsInt, IsOptional, IsString, Length, Max, Min } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class LeaderboardQueryDto {
  @ApiPropertyOptional({ default: 50 })
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
