import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Observable } from 'rxjs';
import * as admin from 'firebase-admin';

import { firebaseConfig } from '../firebaseConfig';

admin.initializeApp(firebaseConfig);

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = request.headers.authorization?.split('Bearer ')[1];

    if (!token) {
      return false;
    }

    return admin
      .auth()
      .verifyIdToken(token)
      .then(() => true)
      .catch(() => false);
  }
}
