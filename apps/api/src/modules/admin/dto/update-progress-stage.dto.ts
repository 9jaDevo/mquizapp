import { PartialType } from '@nestjs/swagger';
import { CreateProgressStageDto } from './create-progress-stage.dto';

export class UpdateProgressStageDto extends PartialType(CreateProgressStageDto) {}
