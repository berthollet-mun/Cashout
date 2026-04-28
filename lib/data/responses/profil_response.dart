import '../models/profil_model.dart';
import 'base_response.dart';

class ProfilResponse extends BaseResponse<ProfilModel> {
  const ProfilResponse({
    required super.success,
    required super.message,
    super.data,
    super.errorCode,
    required super.timestamp,
  });
}
