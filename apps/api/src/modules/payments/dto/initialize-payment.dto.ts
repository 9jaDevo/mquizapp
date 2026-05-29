import { IsEmail, IsInt, IsOptional, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class InitializePaymentDto {
  @ApiProperty() @Type(() => Number) @IsInt() @Min(1) itemId!: number;
  @ApiPropertyOptional() @IsOptional() @IsEmail() email?: string;
}
