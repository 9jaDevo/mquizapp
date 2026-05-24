import { IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class ConsumeBoosterDto {
  @ApiProperty() @Type(() => Number) @IsInt() @Min(1) boosterTypeId!: number;
}
