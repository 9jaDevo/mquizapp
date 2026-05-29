import { PartialType } from '@nestjs/swagger';
import { CreateCoinPackDto } from './create-coin-pack.dto';

export class UpdateCoinPackDto extends PartialType(CreateCoinPackDto) {}
