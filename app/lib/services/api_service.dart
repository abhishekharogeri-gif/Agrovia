import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: const String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:3000'),
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  static Future<Dio> getAuthenticatedDio() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');

    _dio.options.headers['Authorization'] = 'Bearer $token';
    return _dio;
  }
}
