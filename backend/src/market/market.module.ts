import { Module } from '@nestjs/common';
import { MarketService } from './market.service.js';
import { MarketController } from './market.controller.js';

@Module({
  providers: [MarketService],
  controllers: [MarketController],
  exports: [MarketService],
})
export class MarketModule {}
