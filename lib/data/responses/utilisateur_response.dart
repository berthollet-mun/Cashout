import '../models/profile_model.dart';
import 'base_response.dart';

class UtilisateurResponse extends BaseResponse<UtilisateurPayload> {
  const UtilisateurResponse({
    required super.success,
    required super.message,
    super.data,
    super.errorCode,
    required super.timestamp,
  });
}

class UtilisateurPayload {
  final ProfileModel profil;
  final List<String> permissions;
  final Map<String, dynamic> preferences;
  final List<Map<String, dynamic>> historiqueConnexions;
  final String? avatarUrl;

  const UtilisateurPayload({
    required this.profil,
    required this.permissions,
    required this.preferences,
    required this.historiqueConnexions,
    this.avatarUrl,
  });
}
