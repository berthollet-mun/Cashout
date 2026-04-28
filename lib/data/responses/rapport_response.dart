import '../models/outflow_model.dart';
import 'base_response.dart';

class RapportResponse extends BaseResponse<RapportPayload> {
  const RapportResponse({
    required super.success,
    required super.message,
    super.data,
    super.errorCode,
    required super.timestamp,
  });
}

class RapportPayload {
  final DateTime dateDebut;
  final DateTime dateFin;
  final List<OutflowModel> sorties;
  final Map<String, double> totauxParCategorie;
  final List<Map<String, dynamic>> graphiques;
  final double totalGlobal;

  const RapportPayload({
    required this.dateDebut,
    required this.dateFin,
    required this.sorties,
    required this.totauxParCategorie,
    required this.graphiques,
    required this.totalGlobal,
  });
}
