import { IsIn, IsInt, IsOptional, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class RecordImpressionDto {
  @ApiProperty() @Type(() => Number) @IsInt() @Min(1) bannerId!: number;
  @ApiPropertyOptional({ enum: ['showed', 'clicked'] })
  @IsOptional()
  @IsIn(['showed', 'clicked'])
  action: 'showed' | 'clicked' = 'showed';
}
