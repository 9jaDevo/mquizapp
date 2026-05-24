import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDateString,
  IsEnum,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUrl,
  MaxLength,
  Min,
} from 'class-validator';

export enum SponsorRedirectType {
  URL = 'url',
  APPSTORE = 'appstore',
  CUSTOM = 'custom',
}

export enum SponsorImpressionPeriod {
  DAILY = 'daily',
  WEEKLY = 'weekly',
  MONTHLY = 'monthly',
}

export class CreateSponsorDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  sponsorName!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(255)
  title?: string;

  @ApiProperty({ description: 'Banner image URL' })
  @IsString()
  @IsUrl({ require_tld: false })
  @MaxLength(500)
  imageUrl!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @IsUrl({ require_tld: false })
  @MaxLength(500)
  redirectUrl?: string;

  @ApiPropertyOptional({ enum: SponsorRedirectType, default: SponsorRedirectType.URL })
  @IsOptional()
  @IsEnum(SponsorRedirectType)
  redirectType?: SponsorRedirectType;

  @ApiPropertyOptional({ enum: SponsorImpressionPeriod, default: SponsorImpressionPeriod.DAILY })
  @IsOptional()
  @IsEnum(SponsorImpressionPeriod)
  impressionPeriod?: SponsorImpressionPeriod;

  @ApiPropertyOptional({ default: 0, description: '0 = unlimited' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  impressionLimit?: number;

  @ApiProperty({ description: 'ISO date string' })
  @IsDateString()
  startDate!: string;

  @ApiProperty({ description: 'ISO date string' })
  @IsDateString()
  endDate!: string;

  @ApiPropertyOptional({ default: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  priority?: number;

  @ApiPropertyOptional({ default: 1, description: '0 = inactive, 1 = active' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @IsIn([0, 1])
  isActive?: number;
}
