import { Controller, Post, Body, HttpCode, HttpStatus, Headers, UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service.js';

export class FirebaseLoginDto {
  idToken?: string;
}

export class LoginResponseDto {
  accessToken: string;
  userId: string;
  phone: string;
}

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(
    @Headers('authorization') authHeader?: string,
    @Body() dto?: FirebaseLoginDto,
  ): Promise<LoginResponseDto> {
    let idToken: string | undefined;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      idToken = authHeader.split('Bearer ')[1]?.trim();
    } else if (dto?.idToken) {
      idToken = dto.idToken.trim();
    }

    if (!idToken) {
      throw new UnauthorizedException('Missing or malformed Authorization Bearer token / idToken.');
    }

    const { userId, phone } = await this.authService.verifyFirebaseToken(idToken);
    const accessToken = this.authService.signAccessToken({ sub: userId, phone });
    return { accessToken, userId, phone };
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  async refresh(@Body() body: { accessToken: string }): Promise<LoginResponseDto> {
    const decoded = (this.authService as any).jwtService.decode(body.accessToken) as any;
    if (!decoded?.sub || !decoded?.phone) {
      throw new UnauthorizedException('Invalid token for refresh');
    }
    const accessToken = this.authService.signAccessToken({ sub: decoded.sub, phone: decoded.phone });
    return { accessToken, userId: decoded.sub, phone: decoded.phone };
  }
}
