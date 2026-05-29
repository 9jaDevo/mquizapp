import { Type } from 'class-transformer';
import { IsIn, IsInt, IsOptional, IsString, Max, MaxLength, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

const CLASS_LEVELS = [
  'SS1', 'SS2', 'SS3',
  'JSS1', 'JSS2', 'JSS3',
  'Primary 1', 'Primary 2', 'Primary 3', 'Primary 4', 'Primary 5', 'Primary 6',
] as const;

export class GenerateQuestionsDto {
  @ApiProperty({ minLength: 3, maxLength: 200 })
  @IsString()
  @MaxLength(200)
  topic!: string;

  @ApiProperty({ minimum: 1, maximum: 20 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(20)
  count!: number;

  @ApiProperty({ enum: ['easy', 'medium', 'hard'] })
  @IsIn(['easy', 'medium', 'hard'])
  difficultyLevel!: 'easy' | 'medium' | 'hard';

  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  categoryId!: number;

  @ApiPropertyOptional({ description: 'Subject area, e.g. Mathematics' })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  subject?: string;

  @ApiPropertyOptional({ enum: CLASS_LEVELS })
  @IsOptional()
  @IsIn([...CLASS_LEVELS])
  classLevel?: string;
}
