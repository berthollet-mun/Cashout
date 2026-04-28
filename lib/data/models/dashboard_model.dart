// ================================
// 📁 lib/data/models/dashboard_model.dart
// ================================

class DashboardModel {
  final double totalValidated;
  final double totalPending;
  final double totalRejected;
  final double totalCancelled;
  final int    countValidated;
  final int    countPending;
  final int    countRejected;
  final int    countCancelled;
  final double totalThisMonth;
  final double totalBudget;
  final int    totalSorties;
  final double tauxValidation;

  DashboardModel({
    required this.totalValidated,
    required this.totalPending,
    required this.totalRejected,
    required this.totalCancelled,
    required this.countValidated,
    required this.countPending,
    required this.countRejected,
    required this.countCancelled,
    required this.totalThisMonth,
    required this.totalBudget,
    required this.totalSorties,
    required this.tauxValidation,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalValidated: _toDouble(json['total_validated'] ?? json['Montant Validé']),
      totalPending:   _toDouble(json['total_pending']   ?? json['Montant En Attente']),
      totalRejected:  _toDouble(json['total_rejected']  ?? json['Montant Rejeté']),
      totalCancelled: _toDouble(json['total_cancelled'] ?? 0),
      countValidated: _toInt(json['count_validated']    ?? json['Nb Validées']),
      countPending:   _toInt(json['count_pending']      ?? json['Nb En Attente']),
      countRejected:  _toInt(json['count_rejected']     ?? json['Nb Rejetées']),
      countCancelled: _toInt(json['count_cancelled']    ?? json['Nb Annulées']),
      totalThisMonth: _toDouble(json['total_this_month'] ?? json['Validé Ce Mois']),
      totalBudget:    _toDouble(json['total_budget']     ?? json['Budget Total'] ?? 0),
      totalSorties:   _toInt(json['total_sorties']       ?? json['Total Sorties'] ?? 0),
      tauxValidation: _toDouble(json['taux_validation']  ?? json['Taux Validation %'] ?? 0),
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  DashboardModel get empty => DashboardModel(
    totalValidated: 0, totalPending: 0, totalRejected: 0, totalCancelled: 0,
    countValidated: 0, countPending: 0, countRejected: 0, countCancelled: 0,
    totalThisMonth: 0, totalBudget: 0, totalSorties: 0, tauxValidation: 0,
  );
}