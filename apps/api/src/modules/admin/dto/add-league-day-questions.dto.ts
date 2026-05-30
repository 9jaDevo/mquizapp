import { IsArray, IsInt, Min, ArrayMinSize, ArrayMaxSize } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class AddLeagueDayQuestionsDto {
  @ApiProperty({ type: [Number], description: 'Array of question IDs from the main question bank' })
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(100)
  @Type(() => Number)
  @IsInt({ each: true })
  @Min(1, { each: true })
  questionIds!: number[];
}
