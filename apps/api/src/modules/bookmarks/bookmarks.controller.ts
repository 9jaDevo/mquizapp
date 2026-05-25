import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { BookmarksService } from './bookmarks.service';
import { BookmarkQueryDto, CreateBookmarkDto } from './dto/bookmark.dto';
import { PrismaService } from '../../prisma/prisma.service';

@Controller({ path: 'bookmarks', version: '2' })
@UseGuards(FirebaseAuthGuard)
export class BookmarksController {
  constructor(
    private readonly service: BookmarksService,
    private readonly prisma: PrismaService,
  ) {}

  private async resolveUserId(firebaseId: string): Promise<number> {
    const user = await this.prisma.user.findFirst({
      where: { firebaseId: { contains: firebaseId } },
      select: { id: true },
    });
    if (!user) throw new Error('User not found');
    return user.id;
  }

  @Get()
  async list(
    @CurrentUser() token: DecodedIdToken,
    @Query() q: BookmarkQueryDto,
  ) {
    const userId = await this.resolveUserId(token.uid);
    return this.service.listBookmarks(userId, q);
  }

  @Post()
  @Throttle({ default: { ttl: 60_000, limit: 30 } })
  async create(
    @CurrentUser() token: DecodedIdToken,
    @Body() body: CreateBookmarkDto,
  ) {
    const userId = await this.resolveUserId(token.uid);
    return this.service.createBookmark(userId, body);
  }

  @Delete(':questionId')
  @HttpCode(HttpStatus.OK)
  async remove(
    @CurrentUser() token: DecodedIdToken,
    @Param('questionId', ParseIntPipe) questionId: number,
  ) {
    const userId = await this.resolveUserId(token.uid);
    return this.service.deleteBookmark(userId, questionId);
  }
}
