import { IsInt, IsOptional, IsString, MaxLength, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { ListPaginationDto } from './list-pagination.dto';

export class ListUsersQueryDto extends ListPaginationDto {
  @ApiPropertyOptional({ description: 'Filter by status: 0 = active, 1 = banned' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  status?: number;

  @ApiPropertyOptional({ description: 'Filter by Firebase UID (partial match)' })
  @IsOptional()
  @IsString()
  @MaxLength(256)
  firebaseId?: string;
}
