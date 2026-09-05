import { Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { DpdpService } from './dpdp.service.js';
import { JwtAuthGuard } from '../auth/jwt-auth.guard.js';

@UseGuards(JwtAuthGuard)
@Controller('dpdp')
export class DpdpController {
  constructor(private readonly dpdpService: DpdpService) {}

  @Get('export')
  async exportMyData(@Req() req: any) {
    return this.dpdpService.exportUserData(req.user.userId);
  }

  @Post('purge')
  async requestDataPurge(@Req() req: any) {
    return this.dpdpService.revokeConsentAndPurge(req.user.userId);
  }
}
