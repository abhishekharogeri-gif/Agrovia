import { Injectable } from '@nestjs/common';

export interface CommodityPrice {
  id: string;
  commodity: string;
  variety: string;
  marketCenter: string;
  state: string;
  modalPrice: number;
  maxPrice: number;
  minPrice: number;
  trend: 'UP' | 'DOWN' | 'STABLE';
  trendPercentage: number;
  arrivalDate: string;
}

@Injectable()
export class MarketService {
  private readonly prices: CommodityPrice[] = [
    {
      id: 'mkt_1',
      commodity: 'Soybean',
      variety: 'Yellow',
      marketCenter: 'Indore',
      state: 'Madhya Pradesh',
      minPrice: 4700,
      maxPrice: 4950,
      modalPrice: 4850,
      trend: 'UP',
      trendPercentage: 3.2,
      arrivalDate: new Date().toISOString().split('T')[0],
    },
    {
      id: 'mkt_2',
      commodity: 'Onion',
      variety: 'Red',
      marketCenter: 'Lasalgaon',
      state: 'Maharashtra',
      minPrice: 1500,
      maxPrice: 2100,
      modalPrice: 1820,
      trend: 'UP',
      trendPercentage: 5.4,
      arrivalDate: new Date().toISOString().split('T')[0],
    },
    {
      id: 'mkt_3',
      commodity: 'Cotton',
      variety: 'BT',
      marketCenter: 'Guntur',
      state: 'Andhra Pradesh',
      minPrice: 6800,
      maxPrice: 7400,
      modalPrice: 7150,
      trend: 'DOWN',
      trendPercentage: 1.2,
      arrivalDate: new Date().toISOString().split('T')[0],
    },
    {
      id: 'mkt_4',
      commodity: 'Wheat',
      variety: 'Sharbati',
      marketCenter: 'Sehore',
      state: 'Madhya Pradesh',
      minPrice: 2800,
      maxPrice: 3200,
      modalPrice: 2950,
      trend: 'STABLE',
      trendPercentage: 0,
      arrivalDate: new Date().toISOString().split('T')[0],
    },
  ];

  async getLatestPrices(): Promise<CommodityPrice[]> {
    return this.prices;
  }

  async getPriceForecsat(commodity: string, marketCenter: string) {
    // Generate mock forecasting (ARIMA/Prophet equivalent)
    const basePrice = this.prices.find((p) => p.commodity.toLowerCase() === commodity.toLowerCase())?.modalPrice || 5000;

    return {
      commodity,
      marketCenter,
      currentPrice: basePrice,
      forecast7Days: [
        { day: '+1', price: basePrice * 1.01 },
        { day: '+2', price: basePrice * 1.025 },
        { day: '+3', price: basePrice * 1.03 },
        { day: '+4', price: basePrice * 1.01 },
        { day: '+5', price: basePrice * 0.99 },
        { day: '+6', price: basePrice * 0.98 },
        { day: '+7', price: basePrice * 0.985 },
      ],
      aiAdvisory: 'Hold stock for 3 days. Peak expected on Thursday before slight correction.',
    };
  }
}
