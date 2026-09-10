import 'package:flutter_test/flutter_test.dart';
import 'package:agrovia/services/weather_service.dart';

void main() {
  late WeatherService svc;

  setUp(() => svc = WeatherService());

  group('getSprayAdvisory', () {
    test('passes through backend sprayAdvisory string', () {
      final data = {'sprayAdvisory': 'Good Spray Window: Now'};
      expect(svc.getSprayAdvisory(data), 'Good Spray Window: Now');
    });

    test('falls back when sprayAdvisory absent', () {
      expect(svc.getSprayAdvisory({}), 'Check local conditions');
    });

    test('falls back when sprayAdvisory is null', () {
      // Dart maps allow explicit null values
      final data = <String, dynamic>{'sprayAdvisory': null};
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
