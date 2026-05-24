import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class LeagueAnswerDto {
  @ApiProperty() @Type(() => Number) @IsInt() @Min(1) questionId!: number;
  @ApiProperty() @IsString() @MaxLength(512) answer!: string;
}

export class SubmitDailyQuizDto {
  @ApiProperty() @Type(() => Number) @IsInt() @Min(1) dailyQuizId!: number;
  @ApiProperty({ type: [LeagueAnswerDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(50)
  @ValidateNested({ each: true })
  @Type(() => LeagueAnswerDto)
  answers!: LeagueAnswerDto[];
  @ApiPropertyOptional() @IsOptional() @IsBoolean() adShown?: boolean;
}
