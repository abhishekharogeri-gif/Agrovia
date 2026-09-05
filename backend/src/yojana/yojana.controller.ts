import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { YojanaService, CheckEligibilityDto } from './yojana.service.js';
import { JwtAuthGuard } from '../auth/jwt-auth.guard.js';

@UseGuards(JwtAuthGuard)
@Controller('yojana')
export class YojanaController {
  constructor(private readonly yojanaService: YojanaService) {}

  @Get('schemes')
  async getSchemes() {
    return this.yojanaService.getSchemes();
  }

  @Post('eligibility')
  async checkEligibility(@Body() body: CheckEligibilityDto) {
    return this.yojanaService.checkEligibility(body);
  }
}
