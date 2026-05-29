import { IsNotEmpty, IsString, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class VerifyAppleIapDto {
  @ApiProperty({ description: 'Apple IAP product identifier (matches tbl_coin_store.product_id).' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(150)
  productId!: string;

  @ApiProperty({ description: 'Base64-encoded receipt data from StoreKit.' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(200_000)
  receiptData!: string;

  @ApiProperty({ description: 'Apple transaction identifier (used for idempotency).' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  transactionId!: string;
}
