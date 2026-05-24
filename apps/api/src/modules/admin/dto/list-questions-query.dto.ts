import { IsBoolean, IsIn, IsInt, IsOptional, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { ListPaginationDto } from './list-pagination.dto';

export class ListQuestionsQueryDto extends ListPaginationDto {
  @ApiPropertyOptional()
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) categoryId?: number;

  @ApiPropertyOptional({ enum: [1, 2, 3] })
  @IsOptional() @Type(() => Number) @IsInt() @IsIn([1, 2, 3]) difficulty?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  isAi?: boolean;
}
