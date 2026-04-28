/// Réponse de base commune à toutes les opérations réseau.
class BaseResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;
  final DateTime timestamp;

  const BaseResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
    required this.timestamp,
  });

  factory BaseResponse.ok({
    String message = 'Opération réussie',
    T? data,
  }) {
    return BaseResponse(
      success: true,
      message: message,
      data: data,
      timestamp: DateTime.now(),
    );
  }

  factory BaseResponse.fail({
    String message = 'Une erreur est survenue',
    String? errorCode,
  }) {
    return BaseResponse(
      success: false,
      message: message,
      errorCode: errorCode,
      timestamp: DateTime.now(),
    );
  }

  bool get hasData => data != null;
}
