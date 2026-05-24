import { Controller, Get, Param, ParseIntPipe, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CategoriesService } from './categories.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { ListCategoriesQueryDto } from './dto/list-categories-query.dto';

@ApiTags('categories')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Controller({ path: 'categories', version: '2' })
export class CategoriesController {
  constructor(private readonly service: CategoriesService) {}

  @Get()
  @ApiOperation({ summary: 'List active categories' })
  list(@Query() q: ListCategoriesQueryDto) {
    return this.service.listCategories(q);
  }

  @Get(':id/subcategories')
  @ApiOperation({ summary: 'List subcategories of a category' })
  subcategories(@Param('id', ParseIntPipe) id: number, @Query() q: ListCategoriesQueryDto) {
    return this.service.listSubcategories(id, q);
  }
}
