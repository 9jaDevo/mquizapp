import { IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateBookmarkDto {
  @ApiProperty({ description: 'ID of the question to bookmark' })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  questionId!: number;
}

export class BookmarkQueryDto {
  @ApiPropertyOptional({ default: 1 })
  @IsInt()
  @Min(1)
  @Type(() => Number)
  page?: number;

  @ApiPropertyOptional({ default: 20, maximum: 100 })
  @IsInt()
  @Min(1)
  @Type(() => Number)
  limit?: number;
}
