import { Type } from 'class-transformer';
import { IsInt, IsOptional, IsString, IsIn, Max, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

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
}
