// ================================
// 📁 lib/data/models/outflow_log_model.dart
// Modèle pour l'historique des sorties
// ================================

class OutflowLogModel {
  final String id;
  final String outflowId;
  final String action; // 'created', 'validated', 'rejected', 'cancelled', 'updated'
  final String userId;
  final String? comment;
  final Map<String, dynamic>? changes; // Changements effectués
  final DateTime createdAt;

  OutflowLogModel({
    required this.id,
    required this.outflowId,
    required this.action,
    required this.userId,
    this.comment,
    this.changes,
    required this.createdAt,
  });

  factory OutflowLogModel.fromJson(Map<String, dynamic> json) {
    return OutflowLogModel(
      id: json['id'] ?? '',
      outflowId: json['outflow_id'] ?? '',
      action: json['action'] ?? 'unknown',
      userId: json['user_id'] ?? '',
      comment: json['comment'],
      changes: json['changes'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outflow_id': outflowId,
      'action': action,
      'user_id': userId,
      'comment': comment,
      'changes': changes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Obtenir un label lisible pour l'action
  String getActionLabel() {
    switch (action) {
      case 'created':
        return 'Créée';
      case 'validated':
        return 'Validée';
      case 'rejected':
        return 'Rejetée';
      case 'cancelled':
        return 'Annulée';
      case 'updated':
        return 'Modifiée';
      default:
        return action;
    }
  }

  @override
  String toString() => 'OutflowLogModel(id: $id, action: $action, outflowId: $outflowId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutflowLogModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
