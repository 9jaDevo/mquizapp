import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsInt,
  IsString,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ContestAnswerDto {
  @ApiProperty() @Type(() => Number) @IsInt() @Min(1) questionId!: number;
  @ApiProperty() @IsString() @MaxLength(512) answer!: string;
}

export class SubmitContestDto {
  @ApiProperty({ type: [ContestAnswerDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(100)
  @ValidateNested({ each: true })
  @Type(() => ContestAnswerDto)
  answers!: ContestAnswerDto[];
}
