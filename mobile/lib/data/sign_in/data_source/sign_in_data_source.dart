import 'package:dio/dio.dart';
import 'package:mobile/data/datasources/api_client.dart';
import 'package:mobile/data/sign_in/model/sign_in_model.dart';

class SignInDataSource {
  SignInDataSource({required this.apiClient});

  final ApiClient apiClient;

  Dio get _dio => apiClient.dio;

  Future<SignInModel> signIn(String email, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/signin',
        data: {'email': email, 'password': password},
        options: Options(extra: {'auth': false}),
      );
      return SignInModel.fromJson(response.data!);
    } on DioException catch (e) {
      apiClient.throwDio(e);
    }
  }
}
