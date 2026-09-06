import { describe, it, expect, beforeEach } from 'vitest';
import { WeatherService } from './weather.service.js';

describe('WeatherService', () => {
  let svc: WeatherService;

  beforeEach(() => {
    svc = new WeatherService();
  });

  describe('getSprayAdvisory', () => {
    it('returns "not ideal" when wind > 15', () => {
      expect((svc as any).getSprayAdvisory(16, 25)).toBe('Not ideal for spraying');
    });
    it('returns "not ideal" when temp > 35', () => {
      expect((svc as any).getSprayAdvisory(5, 36)).toBe('Not ideal for spraying');
    });
    it('returns "good" when wind < 5 and temp < 30', () => {
      expect((svc as any).getSprayAdvisory(4, 29)).toBe('Good Spray Window: Now');
    });
    it('returns "fair" for moderate conditions', () => {
      expect((svc as any).getSprayAdvisory(8, 30)).toBe('Fair Spray Window');
    });
  });

  describe('getWeather', () => {
    it('returns mock data when no API key is set', async () => {
      const result = await svc.getWeather();
      expect(result.city).toBe('Indore');
      expect(result.temp).toBe(28);
      expect(result.sprayAdvisory).toBe('Good Spray Window: Now');
    });
  });
});
