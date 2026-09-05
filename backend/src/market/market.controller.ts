import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { MarketService } from './market.service.js';
import { JwtAuthGuard } from '../auth/jwt-auth.guard.js';

@UseGuards(JwtAuthGuard)
@Controller('market')
export class MarketController {
  constructor(private readonly marketService: MarketService) {}

  @Get('prices')
  async getPrices() {
    return this.marketService.getLatestPrices();
  }

  @Get('forecast')
  async getForecast(@Query('crop') crop: string, @Query('mandi') mandi: string) {
    return this.marketService.getPriceForecsat(crop, mandi);
  }
}
