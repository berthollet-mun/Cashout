import '../models/outflow_model.dart';
import 'base_response.dart';

class SortieResponse extends BaseResponse<SortiePayload> {
  const SortieResponse({
    required super.success,
    required super.message,
    super.data,
    super.errorCode,
    required super.timestamp,
  });
}

class SortiePayload {
  final OutflowModel sortie;
  final double totalCalcule;
  final String statut;
  final String numeroDocument;
  final List<Map<String, dynamic>> articles;

  const SortiePayload({
    required this.sortie,
    required this.totalCalcule,
    required this.statut,
    required this.numeroDocument,
    required this.articles,
  });
}
