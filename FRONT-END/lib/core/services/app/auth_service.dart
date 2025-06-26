import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../dto/auth/request/change_password_dto.dart';
import '../../../dto/auth/request/login_user_dto.dart';
import '../../../dto/auth/request/new_user_dto.dart';
import '../../../dto/auth/request/send_verification_code_dto.dart';
import '../../../dto/auth/request/validate_verification_code_dto.dart';
import '../../../dto/auth/response/token_response_dto.dart';
import '../../exceptions/api_response.dart';
import '../api_client.dart';

class AuthService {
  final _api = ApiClient();
  final _storage = const FlutterSecureStorage();

  //Verificar si el servicio puede funcionar correctamente
  bool get isReady => _api.isInitialized;

  Future<TokenResponseDTO> login(LoginUserDTO dto) async {
    final response = await _api.postApp('/auth/login', dto.toJson());
    final json = response.data;
    final apiResponse = ApiResponse<TokenResponseDTO>.fromJson(
      json,
          (data) => TokenResponseDTO.fromJson(data),
    );
    await _storage.write(key: 'Authorization', value: apiResponse.data.token);
    return apiResponse.data;
  }

  Future<void> register(NewUserDTO dto) async {
    await _api.postApp('/auth/register', dto.toJson());
  }

  Future<void> sendVerificationCode({
    required bool isRegistration,
    required SendVerificationCodeDTO dto,
  }) async {
    await _api.postApp(
      '/auth/send-verification-code?isRegistration=$isRegistration',
      dto.toJson(),
    );
  }

  Future<void> validateVerificationCode(ValidateVerificationCodeDTO dto) async {
    await _api.postApp(
      '/auth/validate-verification-code',
      dto.toJson(),
    );
  }

  Future<void> changePasswordWithCode(ChangePasswordDTO dto) async {
    await _api.putApp('/auth/change-password', dto.toJson());
  }

  Future<void> logout() async {
    await _api.postApp('/auth/logout', {});
    await _storage.delete(key: 'Authorization');
  }

  Future<void> deleteUser(String userId) async {
    await _api.deleteApp('/auth/$userId');
  }
}