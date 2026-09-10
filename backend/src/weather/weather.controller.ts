import { Controller, Get, Query } from '@nestjs/common';
import { WeatherService } from './weather.service.js';

@Controller('weather')
export class WeatherController {
  constructor(private readonly weatherService: WeatherService) {}

  @Get()
  async getWeather(
    @Query('city') city?: string,
    @Query('lat') lat?: number,
    @Query('lon') lon?: number,
  ) {
    const result = await this.weatherService.getWeather(city ?? 'Indore,IN', lat, lon);
    return result;
  }
}
