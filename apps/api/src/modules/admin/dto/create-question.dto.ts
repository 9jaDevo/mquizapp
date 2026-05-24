import { Type } from 'class-transformer';
import {
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateQuestionDto {
  @ApiProperty() @Type(() => Number) @IsInt() @Min(1) category!: number;
  @ApiProperty() @Type(() => Number) @IsInt() @Min(0) subcategory!: number;
  @ApiPropertyOptional({ default: 0 }) @IsOptional() @Type(() => Number) @IsInt() @Min(0) languageId?: number;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(512) image?: string;
  @ApiProperty() @IsString() @MaxLength(4000) question!: string;
  @ApiProperty({ description: '0=MCQ, 1=true/false, 2=fill-blank' }) @Type(() => Number) @IsInt() @Min(0) @Max(10) questionType!: number;
  @ApiProperty() @IsString() @MaxLength(1024) optiona!: string;
  @ApiProperty() @IsString() @MaxLength(1024) optionb!: string;
  @ApiProperty() @IsString() @MaxLength(1024) optionc!: string;
  @ApiProperty() @IsString() @MaxLength(1024) optiond!: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(1024) optione?: string;
  @ApiProperty({ description: 'Correct answer key: a, b, c, d, or e' }) @IsString() @MaxLength(512) answer!: string;
  @ApiProperty({ description: '1–10 difficulty level' }) @Type(() => Number) @IsInt() @Min(0) @Max(10) level!: number;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(2048) note?: string;
}
