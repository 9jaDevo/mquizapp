import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { envValidationSchema } from './config/env.validation';
import { PrismaModule } from './prisma/prisma.module';
import { RedisModule } from './redis/redis.module';
import { FirebaseModule } from './firebase/firebase.module';

import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { CategoriesModule } from './modules/categories/categories.module';
import { ConfigDataModule } from './modules/config/config.module';
import { StreakModule } from './modules/streak/streak.module';
import { LeaderboardModule } from './modules/leaderboard/leaderboard.module';
import { QuizModule } from './modules/quiz/quiz.module';
import { CoinsModule } from './modules/coins/coins.module';
import { LivesModule } from './modules/lives/lives.module';
import { BoostersModule } from './modules/boosters/boosters.module';
import { ProgressModule } from './modules/progress/progress.module';
import { AdsModule } from './modules/ads/ads.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { ReferralModule } from './modules/referral/referral.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { LeagueModule } from './modules/league/league.module';
import { ContestModule } from './modules/contest/contest.module';
import { AdminModule } from './modules/admin/admin.module';
import { BookmarksModule } from './modules/bookmarks/bookmarks.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      cache: true,
      validationSchema: envValidationSchema,
      validationOptions: { abortEarly: false },
    }),
    ThrottlerModule.forRoot([
      { name: 'default', ttl: 60_000, limit: 60 },
    ]),
    ScheduleModule.forRoot(),
    PrismaModule,
    RedisModule,
    FirebaseModule,

    AuthModule,
    UsersModule,
    CategoriesModule,
    ConfigDataModule,
    StreakModule,
    LeaderboardModule,
    QuizModule,
    CoinsModule,
    LivesModule,
    BoostersModule,
    ProgressModule,
    AdsModule,
    NotificationsModule,
    ReferralModule,
    PaymentsModule,
    LeagueModule,
    ContestModule,
    AdminModule,
    BookmarksModule,
  ],
  providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }],
})
export class AppModule {}
