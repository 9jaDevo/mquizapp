import { Type } from 'class-transformer';
import { IsInt, IsOptional, IsString, MaxLength, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateCoinPackDto {
  @ApiProperty({ description: 'Display title (max 50 chars).' })
  @IsString()
  @MaxLength(50)
  title!: string;

  @ApiProperty({ description: 'Coins awarded on purchase.', minimum: 1 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  coins!: number;

  @ApiProperty({ description: 'Price in kobo (NGN minor units).', minimum: 0 })
  @Type(() => Number)
  @IsInt()
  @Min(0)
  priceKobo!: number;

  @ApiProperty({ required: false, description: 'IAP product identifier.' })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  productId?: string;

  @ApiProperty({ required: false, description: 'Image URL.' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  imageUrl?: string;

  @ApiProperty({ required: false, description: 'Long description.' })
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  description?: string;
}
