import { IsEnum, IsInt, IsOptional, IsString, IsUrl, Max, MaxLength, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateContestQuestionDto {
  @ApiProperty() @IsString() @MaxLength(2000) question!: string;
  @ApiProperty() @IsString() @MaxLength(512) optiona!: string;
  @ApiProperty() @IsString() @MaxLength(512) optionb!: string;
  @ApiProperty() @IsString() @MaxLength(512) optionc!: string;
  @ApiProperty() @IsString() @MaxLength(512) optiond!: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(512) optione?: string;
  @ApiProperty({ enum: ['a', 'b', 'c', 'd', 'e'] }) @IsEnum(['a', 'b', 'c', 'd', 'e']) answer!: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(500) image?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(2000) note?: string;
  @ApiPropertyOptional() @IsOptional() @Type(() => Number) @IsInt() @Min(0) languageId?: number;
}
