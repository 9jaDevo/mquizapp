import { Global, Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { FirebaseService } from './firebase.service';

export const FIREBASE_APP = Symbol('FIREBASE_APP');

@Global()
@Module({
  imports: [ConfigModule],
  providers: [
    {
      provide: FIREBASE_APP,
      inject: [ConfigService],
      useFactory: (config: ConfigService): admin.app.App => {
        if (admin.apps.length > 0) return admin.apps[0] as admin.app.App;

        const projectId = config.getOrThrow<string>('FIREBASE_PROJECT_ID');
        const clientEmail = config.getOrThrow<string>('FIREBASE_CLIENT_EMAIL');
        const privateKey = config
          .getOrThrow<string>('FIREBASE_PRIVATE_KEY')
          .replace(/\\n/g, '\n');

        return admin.initializeApp({
          credential: admin.credential.cert({ projectId, clientEmail, privateKey }),
        });
      },
    },
    FirebaseService,
  ],
  exports: [FirebaseService, FIREBASE_APP],
})
export class FirebaseModule {}
