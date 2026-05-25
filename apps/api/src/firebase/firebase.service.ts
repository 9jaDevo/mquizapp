import { Inject, Injectable } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { FIREBASE_APP } from './firebase.constants';

@Injectable()
export class FirebaseService {
  constructor(@Inject(FIREBASE_APP) private readonly app: admin.app.App) {}

  auth(): admin.auth.Auth {
    return this.app.auth();
  }

  messaging(): admin.messaging.Messaging {
    return this.app.messaging();
  }

  async verifyIdToken(token: string): Promise<admin.auth.DecodedIdToken> {
    return this.auth().verifyIdToken(token, true);
  }
}
