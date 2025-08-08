import 'package:dio/dio.dart';

/// Creates a configured Dio instance for API calls.
Dio createDio() {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      contentType: 'application/json',
    ),
  );
  return dio;
}
