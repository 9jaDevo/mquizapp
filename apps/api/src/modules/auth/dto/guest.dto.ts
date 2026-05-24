import { IsOptional, IsString, MaxLength } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class GuestDto {
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(128) name?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(64) appLanguage?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(3) countryCode?: string;
}
