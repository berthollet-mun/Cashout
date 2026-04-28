import '../models/outflow_model.dart';
import 'base_response.dart';

class DashboardResponse extends BaseResponse<DashboardPayload> {
  const DashboardResponse({
    required super.success,
    required super.message,
    super.data,
    super.errorCode,
    required super.timestamp,
  });
}

class DashboardPayload {
  final double totalJour;
  final double totalMois;
  final double comparaisonMoisPrecedent;
  final List<Map<String, dynamic>> topCategories;
  final List<OutflowModel> dernieresTransactions;
  final List<String> alertes;

  const DashboardPayload({
    required this.totalJour,
    required this.totalMois,
    required this.comparaisonMoisPrecedent,
    required this.topCategories,
    required this.dernieresTransactions,
    required this.alertes,
  });
}
