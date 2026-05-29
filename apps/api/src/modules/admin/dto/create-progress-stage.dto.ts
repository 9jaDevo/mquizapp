import { Type } from 'class-transformer';
import { IsBoolean, IsInt, IsOptional, IsString, MaxLength, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateProgressStageDto {
  @ApiProperty({ description: 'Stage ordering number (unique).', minimum: 1 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  stageNumber!: number;

  @ApiProperty({ description: 'Stage display name.' })
  @IsString()
  @MaxLength(128)
  name!: string;

  @ApiProperty({ description: 'Minimum XP/score required to reach this stage.', minimum: 0 })
  @Type(() => Number)
  @IsInt()
  @Min(0)
  minScore!: number;

  @ApiProperty({ required: false, description: 'Icon URL.' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  iconUrl?: string;

  @ApiProperty({ required: false, description: 'Whether the stage is active.' })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
