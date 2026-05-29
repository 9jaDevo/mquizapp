import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateAiQuestionDto {
  @ApiPropertyOptional()
  @IsOptional() @IsString() @MaxLength(4000)
  question?: string;

  @ApiPropertyOptional()
  @IsOptional() @IsString() @MaxLength(1000)
  optiona?: string;

  @ApiPropertyOptional()
  @IsOptional() @IsString() @MaxLength(1000)
  optionb?: string;

  @ApiPropertyOptional()
  @IsOptional() @IsString() @MaxLength(1000)
  optionc?: string;

  @ApiPropertyOptional()
  @IsOptional() @IsString() @MaxLength(1000)
  optiond?: string;

  @ApiPropertyOptional({ enum: ['a', 'b', 'c', 'd'] })
  @IsOptional() @IsString() @IsIn(['a', 'b', 'c', 'd'])
  answer?: string;

  @ApiPropertyOptional()
  @IsOptional() @IsString() @MaxLength(500)
  note?: string;
}
