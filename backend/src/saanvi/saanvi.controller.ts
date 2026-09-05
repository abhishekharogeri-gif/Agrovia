import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { SaanviService, SaanviQueryDto } from './saanvi.service.js';
import { JwtAuthGuard } from '../auth/jwt-auth.guard.js';

@UseGuards(JwtAuthGuard)
@Controller('saanvi')
export class SaanviController {
  constructor(private readonly saanviService: SaanviService) {}

  @Post('query')
  async askSaanvi(@Body() body: SaanviQueryDto) {
    return this.saanviService.processQuery(body);
  }
}
