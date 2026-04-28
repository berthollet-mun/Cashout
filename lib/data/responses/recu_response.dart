import '../models/outflow_model.dart';
import 'base_response.dart';

class RecuResponse extends BaseResponse<RecuPayload> {
  const RecuResponse({
    required super.success,
    required super.message,
    super.data,
    super.errorCode,
    required super.timestamp,
  });
}

class RecuPayload {
  final String numeroRecu;
  final OutflowModel transaction;
  final String montantEnLettres;
  final String qrCodeData;
  final String? pdfUrl;

  const RecuPayload({
    required this.numeroRecu,
    required this.transaction,
    required this.montantEnLettres,
    required this.qrCodeData,
    this.pdfUrl,
  });
}
