import { ApiProperty } from '@nestjs/swagger';
import { IsDateString, IsInt, IsOptional, Max, Min } from 'class-validator';

export class AssignLeagueDayDto {
  @ApiProperty({ description: 'Day number (1-based)', example: 1 })
  @IsInt()
  @Min(1)
  @Max(365)
  quizDay!: number;

  @ApiProperty({ description: 'Calendar date for this quiz day (ISO)', example: '2025-07-01' })
  @IsDateString()
  quizDate!: string;

  @ApiProperty({ description: 'Number of questions to draw for this day', default: 20, required: false })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  questionCount?: number;
}
