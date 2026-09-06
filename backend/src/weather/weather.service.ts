import { Injectable } from '@nestjs/common';

@Injectable()
export class WeatherService {
  private readonly apiKey = process.env.OPENWEATHER_API_KEY ?? '';
  private readonly baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  private getSprayAdvisory(windSpeed: number, temp: number): string {
    if (windSpeed > 15 || temp > 35) return 'Not ideal for spraying';
    if (windSpeed < 5 && temp < 30) return 'Good Spray Window: Now';
    return 'Fair Spray Window';
  }

  async getWeather(city = 'Indore,IN') {
    if (!this.apiKey) {
      return {
        city: 'Indore',
        country: 'IN',
        temp: 28,
        feelsLike: 30,
        humidity: 65,
        windSpeed: 6,
        description: 'clear sky',
        icon: '01d',
        sprayAdvisory: 'Good Spray Window: Now',
      };
    }

    try {
      const url = new URL(this.baseUrl);
      url.searchParams.set('q', city);
      url.searchParams.set('units', 'metric');
      url.searchParams.set('appid', this.apiKey);

      const response = await fetch(url.toString());
      if (!response.ok) return null;
      const data: any = await response.json();

      return {
        city: data.name,
        country: data.sys.country,
        temp: Math.round(data.main.temp),
        feelsLike: Math.round(data.main.feels_like),
        humidity: data.main.humidity,
        windSpeed: data.wind.speed,
        description: data.weather[0].description,
        icon: data.weather[0].icon,
        sprayAdvisory: this.getSprayAdvisory(data.wind.speed, data.main.temp),
      };
    } catch {
      return null;
    }
  }
}
