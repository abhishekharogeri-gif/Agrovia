import { Controller, Get, Query } from '@nestjs/common';
import { WeatherService } from './weather.service.js';

@Controller('weather')
export class WeatherController {
  constructor(private readonly weatherService: WeatherService) {}

  @Get()
  async getWeather(@Query('city') city?: string) {
    const result = await this.weatherService.getWeather(city ?? 'Indore,IN');
    return result;
  }
}
