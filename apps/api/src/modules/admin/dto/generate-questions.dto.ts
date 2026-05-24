import { Type } from 'class-transformer';
import { IsIn, IsInt, IsString, Max, MaxLength, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

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
}
