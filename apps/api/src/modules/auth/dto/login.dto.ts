import { IsEmail, IsOptional, IsString, MaxLength } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class LoginDto {
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(128) name?: string;
  @ApiPropertyOptional() @IsOptional() @IsEmail() @MaxLength(128) email?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(32) mobile?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(128) profile?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(16) type?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(128) friendsCode?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(64) appLanguage?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(3) countryCode?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(100) countryName?: string;
}
