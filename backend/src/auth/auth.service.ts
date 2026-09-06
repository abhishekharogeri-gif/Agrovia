import { Injectable, UnauthorizedException, OnModuleInit } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

export interface JwtPayload {
  sub: string; // user id
  phone: string;
  iat?: number;
  exp?: number;
}

@Injectable()
export class AuthService implements OnModuleInit {
  private firebaseApp: admin.app.App | null = null;

  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  onModuleInit() {
    if (admin.apps.length > 0) {
      this.firebaseApp = admin.app();
      return;
    }

    const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID') || 'agrovia-db202';
    const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');
    let privateKey = this.configService.get<string>('FIREBASE_PRIVATE_KEY');

    try {
      if (clientEmail && privateKey) {
        // Unescape multiline private keys passed through .env files
        privateKey = privateKey.replace(/\\n/g, '\n');
        this.firebaseApp = admin.initializeApp({
          credential: admin.credential.cert({
            projectId,
            clientEmail,
            privateKey,
          }),
        });
      } else {
        // Fall back to GOOGLE_APPLICATION_CREDENTIALS or Application Default Credentials
        this.firebaseApp = admin.initializeApp({
          credential: admin.credential.applicationDefault(),
        });
      }
    } catch (_) {
      this.firebaseApp = null;
    }
  }

  async verifyFirebaseToken(idToken: string): Promise<{ userId: string; phone: string }> {
    if (!idToken) {
      throw new UnauthorizedException('Missing Firebase ID token.');
    }

    if (!this.firebaseApp) {
      throw new UnauthorizedException(
        'Firebase Admin SDK not initialized. Set FIREBASE_CLIENT_EMAIL & FIREBASE_PRIVATE_KEY or GOOGLE_APPLICATION_CREDENTIALS.',
      );
    }

    try {
      const decoded = await admin.auth(this.firebaseApp).verifyIdToken(idToken);
      const uid = decoded.uid;
      const phone = decoded.phone_number;
      if (!uid) throw new UnauthorizedException('Token missing user ID.');
      return { userId: uid, phone: phone || '' };
    } catch (_) {
      throw new UnauthorizedException('Invalid or expired Firebase ID token.');
    }
  }

  signAccessToken(payload: JwtPayload): string {
    return this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_SECRET', 'default-secret'),
      expiresIn: '7d',
    });
  }
}
