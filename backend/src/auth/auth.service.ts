import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';

export interface JwtPayload {
  sub: string; // user id
  phone: string;
  iat?: number;
  exp?: number;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async verifyFirebaseToken(idToken: string): Promise<{ userId: string; phone: string }> {
    if (!idToken || idToken.length < 8) {
      throw new UnauthorizedException('Invalid Firebase ID token.');
    }
    if (idToken.startsWith('mock.')) {
      const [, uid, phone] = idToken.split('.');
      if (!uid || !phone) throw new UnauthorizedException('Malformed mock token.');
      return { userId: uid, phone };
    }
    throw new UnauthorizedException('Firebase verification not yet wired.');
  }

  signAccessToken(payload: JwtPayload): string {
    return this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_SECRET', 'default-secret'),
      expiresIn: '7d', // Just hardcode to avoid TS StringValue complaints for now
    });
  }
}
