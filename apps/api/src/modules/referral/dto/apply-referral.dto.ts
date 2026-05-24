import { IsOptional, IsString, Length } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ApplyReferralDto {
  @ApiProperty() @IsString() @Length(4, 50) code!: string;
  @ApiPropertyOptional() @IsOptional() @IsString() signupIp?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() deviceId?: string;
}
