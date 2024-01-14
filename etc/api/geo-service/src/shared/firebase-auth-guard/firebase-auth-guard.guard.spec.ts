import { FirebaseAuthGuard } from './firebase-auth-guard.guard';

describe('FirebaseAuthGuardGuard', () => {
  it('should be defined', () => {
    expect(new FirebaseAuthGuard()).toBeDefined();
  });
});
