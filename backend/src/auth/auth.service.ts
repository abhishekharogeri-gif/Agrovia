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
    // Initialize Firebase Admin SDK if credentials are available
    // Expects GOOGLE_APPLICATION_CREDENTIALS env var pointing to service account JSON
    // or Application Default Credentials in GCP / Render / Cloud Run
    try {
      if (!admin.apps.length) {
        this.firebaseApp = admin.initializeApp({
          credential: admin.credential.applicationDefault(),
        });
      } else {
        this.firebaseApp = admin.app();
      }
    } catch (e) {
      // In local dev without creds, we'll fall back to mock path
      this.firebaseApp = null;
    }
  }

  async verifyFirebaseToken(idToken: string): Promise<{ userId: string; phone: string }> {
    if (!idToken || idToken.length < 8) {
      throw new UnauthorizedException('Invalid Firebase ID token.');
    }

    // Mock path for local development without Firebase credentials
    if (idToken.startsWith('mock.')) {
      const [, uid, phone] = idToken.split('.');
      if (!uid || !phone) throw new UnauthorizedException('Malformed mock token.');
      return { userId: uid, phone };
    }

    // Production path: verify real Firebase ID token via Admin SDK
    if (!this.firebaseApp) {
      throw new UnauthorizedException('Firebase Admin SDK not initialized. Set GOOGLE_APPLICATION_CREDENTIALS.');
    }

    try {
      const decoded = await admin.auth(this.firebaseApp).verifyIdToken(idToken);
      const uid = decoded.uid;
      const phone = decoded.phone_number;
      if (!uid) throw new UnauthorizedException('Token missing user ID.');
      return { userId: uid, phone: phone || '' };
    } catch (e) {
      throw new UnauthorizedException('Invalid or expired Firebase ID token.');
    }
  }

  signAccessToken(payload: JwtPayload): string {
    return this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_SECRET', 'default-secret'),
      expiresIn: '7d', // Just hardcode to avoid TS StringValue complaints for now
    });
  }
}