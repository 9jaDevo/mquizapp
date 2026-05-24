import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateFcmTokenDto {
  @ApiProperty() @IsString() @MaxLength(1024) token!: string;

  @ApiPropertyOptional({ enum: ['mobile', 'web'] })
  @IsOptional()
  @IsIn(['mobile', 'web'])
  platform?: 'mobile' | 'web';
}
