import 'package:dio/dio.dart';

class WeatherService {
  static String get _primaryKey =>
      const String.fromEnvironment('OPENWEATHER_API_KEY', defaultValue: '');

  static String get _fallbackKey =>
      const String.fromEnvironment('OPENWEATHER_API_KEY_FALLBACK', defaultValue: '');

  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> fetchWeather({String? city, double? lat, double? lon}) async {
    final keys = [_primaryKey, _fallbackKey].where((k) => k.isNotEmpty).toList();
    if (keys.isEmpty) return null;

    final params = {'units': 'metric'};
    if (lat != null && lon != null) {
      params['lat'] = lat.toString();
      params['lon'] = lon.toString();
    } else {
      params['q'] = city ?? 'Indore,IN';
    }

    for (final key in keys) {
      params['appid'] = key;
      try {
        final response = await _dio.get(_baseUrl, queryParameters: params);
        return response.data as Map<String, dynamic>;
      } catch (_) {
        // try next key
      }
    }
    return null;
  }

  String getSprayAdvisory(Map<String, dynamic> weatherData) {
    if (weatherData['wind'] == null || weatherData['main'] == null) {
      return 'Check local conditions';
    }
    final double windSpeed = (weatherData['wind']['speed'] as num).toDouble();
    final double temp = (weatherData['main']['temp'] as num).toDouble();

    if (windSpeed > 15 || temp > 35) {
      return 'Not ideal for spraying';
    } else if (windSpeed < 5 && temp < 30) {
      return 'Good Spray Window: Now';
    } else {
      return 'Fair Spray Window';
    }
  }

  String getWeatherIcon(String? iconCode) {
    if (iconCode == null) return '☀️';
    switch (iconCode.substring(0, 2)) {
      case '01': return '☀️';
      case '02': return '⛅';
      case '03': return '☁️';
      case '04': return '☁️';
      case '09': return '🌧️';
      case '10': return '🌦️';
      case '11': return '⛈️';
      case '13': return '❄️';
      case '50': return '🌫️';
      default:  return '☀️';
    }
  }
}
