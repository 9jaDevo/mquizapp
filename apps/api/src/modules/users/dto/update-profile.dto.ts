import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateProfileDto {
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(128) name?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(128) profile?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(32) mobile?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(64) appLanguage?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(3) countryCode?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(100) countryName?: string;
  @ApiPropertyOptional({ enum: ['child', 'teen', 'adult', 'senior'] })
  @IsOptional() @IsString() @IsIn(['child', 'teen', 'adult', 'senior'])
  ageGroup?: string;
}
