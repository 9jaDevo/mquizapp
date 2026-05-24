import { Type } from 'class-transformer';
import { ArrayMaxSize, IsArray, IsInt, IsOptional, IsString, MaxLength, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SendNotificationDto {
  @ApiProperty() @IsString() @MaxLength(128) title!: string;
  @ApiProperty() @IsString() @MaxLength(2048) message!: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(64) type?: string;
  @ApiPropertyOptional() @IsOptional() @Type(() => Number) @IsInt() @Min(0) typeId?: number;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(256) image?: string;
  @ApiPropertyOptional({ type: [Number], description: 'Empty → broadcast to topic; non-empty → multicast' })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(1000)
  @Type(() => Number)
  @IsInt({ each: true })
  userIds?: number[];
}
