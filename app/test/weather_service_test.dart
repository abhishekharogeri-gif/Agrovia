import 'package:flutter_test/flutter_test.dart';
import 'package:agrovia/services/weather_service.dart';

void main() {
  late WeatherService svc;

  setUp(() => svc = WeatherService());

  group('getSprayAdvisory', () {
    test('returns "not ideal" when wind > 15 m/s', () {
      final data = {
        'main': {'temp': 25.0},
        'wind': {'speed': 16.0},
      };
      expect(svc.getSprayAdvisory(data), 'Not ideal for spraying');
    });

    test('returns "not ideal" when temp > 35°C', () {
      final data = {
        'main': {'temp': 36.0},
        'wind': {'speed': 5.0},
      };
      expect(svc.getSprayAdvisory(data), 'Not ideal for spraying');
    });

    test('returns "good" when wind < 5 m/s and temp < 30°C', () {
      final data = {
        'main': {'temp': 28.0},
        'wind': {'speed': 4.0},
      };
      expect(svc.getSprayAdvisory(data), 'Good Spray Window: Now');
    });

    test('returns "fair" for moderate conditions', () {
      final data = {
        'main': {'temp': 30.0},
        'wind': {'speed': 8.0},
      };
      expect(svc.getSprayAdvisory(data), 'Fair Spray Window');
    });

    test('returns fallback when wind data missing', () {
      final data = {'main': {'temp': 25.0}};
      expect(svc.getSprayAdvisory(data), 'Check local conditions');
    });

    test('returns fallback when main data missing', () {
      final data = {'wind': {'speed': 8.0}};
      expect(svc.getSprayAdvisory(data), 'Check local conditions');
    });
  });

  group('getWeatherIcon', () {
    test('maps 01x to clear sun', () => expect(svc.getWeatherIcon('01d'), '☀️'));
    test('maps 02x to few clouds', () => expect(svc.getWeatherIcon('02n'), '⛅'));
    test('maps 03x to scattered clouds', () => expect(svc.getWeatherIcon('03d'), '☁️'));
    test('maps 04x to broken clouds', () => expect(svc.getWeatherIcon('04n'), '☁️'));
    test('maps 09x to shower rain', () => expect(svc.getWeatherIcon('09d'), '🌧️'));
    test('maps 10x to rain', () => expect(svc.getWeatherIcon('10n'), '🌦️'));
    test('maps 11x to thunderstorm', () => expect(svc.getWeatherIcon('11d'), '⛈️'));
    test('maps 13x to snow', () => expect(svc.getWeatherIcon('13n'), '❄️'));
    test('maps 50x to mist', () => expect(svc.getWeatherIcon('50d'), '🌫️'));
    test('null defaults to sun', () => expect(svc.getWeatherIcon(null), '☀️'));
    test('unknown defaults to sun', () => expect(svc.getWeatherIcon('99d'), '☀️'));
  });
}
