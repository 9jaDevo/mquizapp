import { IsEnum, IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export type QuestionSource = 'quiz' | 'contest';

export class FiftyFiftyDto {
  @ApiProperty() @Type(() => Number) @IsInt() @Min(1) questionId!: number;
  @ApiProperty() @Type(() => Number) @IsInt() @Min(1) boosterTypeId!: number;
  @ApiProperty({ enum: ['quiz', 'contest'], default: 'quiz' })
  @IsEnum(['quiz', 'contest'])
  source: QuestionSource = 'quiz';
}
