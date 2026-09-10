import 'api_service.dart';

class WeatherService {
  Future<Map<String, dynamic>?> fetchWeather({String? city, double? lat, double? lon}) async {
    try {
      final dio = await ApiService.getAuthenticatedDio();

      final queryParams = <String, dynamic>{};
      if (lat != null && lon != null) {
        queryParams['lat'] = lat.toString();
        queryParams['lon'] = lon.toString();
      }
      if (city != null) {
        queryParams['city'] = city;
      }

      final response = await dio.get('/weather', queryParameters: queryParams);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Uses the string output provided directly by the backend!
  String getSprayAdvisory(Map<String, dynamic> weatherData) {
    if (weatherData['sprayAdvisory'] != null) {
      return weatherData['sprayAdvisory'] as String;
    }
    return 'Check local conditions';
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
