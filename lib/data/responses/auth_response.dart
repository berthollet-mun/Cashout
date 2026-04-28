import '../models/profile_model.dart';
import 'base_response.dart';

/// Réponse d'authentification complète.
class AuthResponse extends BaseResponse<AuthPayload> {
  const AuthResponse({
    required super.success,
    required super.message,
    super.data,
    super.errorCode,
    required super.timestamp,
  });

  factory AuthResponse.success({
    required AuthPayload payload,
    String message = 'Connexion réussie',
  }) {
    return AuthResponse(
      success: true,
      message: message,
      data: payload,
      timestamp: DateTime.now(),
    );
  }

  factory AuthResponse.error({
    String message = 'Echec de connexion',
    String? errorCode,
  }) {
    return AuthResponse(
      success: false,
      message: message,
      errorCode: errorCode,
      timestamp: DateTime.now(),
    );
  }
}

class AuthPayload {
  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;
  final ProfileModel? user;
  final List<String> permissions;

  const AuthPayload({
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
    this.user,
    this.permissions = const [],
  });

  factory AuthPayload.fromJson(Map<String, dynamic> json) {
    return AuthPayload(
      accessToken: (json['access_token'] ?? '').toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.tryParse(json['expires_at'].toString()),
      user: json['user'] is Map<String, dynamic>
          ? ProfileModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      permissions: (json['permissions'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt?.toIso8601String(),
      'user': user?.toJson(),
      'permissions': permissions,
    };
  }
}

/// Compatibilité avec l'ancien nom utilisé dans le projet.
typedef AuthResponseModel = AuthResponse;
