import { Type } from 'class-transformer';
import { IsInt, IsNotEmpty, IsString, MaxLength, NotEquals } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AdjustCoinsDto {
  @ApiProperty({ description: 'Positive to add coins, negative to deduct. Cannot be zero.' })
  @Type(() => Number)
  @IsInt()
  @NotEquals(0)
  amount!: number;

  @ApiProperty({ description: 'Reason for the adjustment (for audit trail)' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  reason!: string;
}
