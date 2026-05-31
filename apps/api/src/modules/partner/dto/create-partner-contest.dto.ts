import {
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

export enum ContestVisibility {
  PUBLIC = 'public',
  PRIVATE = 'private',
}

export class CreatePartnerContestDto {
  @IsString()
  @MaxLength(255)
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  @MaxLength(512)
  bannerUrl?: string;

  @IsOptional()
  @IsDateString()
  startDate?: string;

  @IsOptional()
  @IsDateString()
  endDate?: string;

  @IsEnum(ContestVisibility)
  visibility: ContestVisibility;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(1_000_000)
  maxParticipants?: number;

  @IsOptional()
  @IsInt()
  @Min(5)
  @Max(300)
  timeLimitSeconds?: number;

  @IsOptional()
  @IsString()
  prizeDescription?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  coinPrizePool?: number;

  @IsOptional()
  allowRetakes?: boolean;

  @IsOptional()
  @IsString()
  customJoinMessage?: string;

  @IsOptional()
  @IsString()
  customCompleteMessage?: string;
}
