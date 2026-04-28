// ================================
// 📁 lib/data/responses/api_response.dart
// ================================

/// Wrapper générique pour toutes les réponses API
class ApiResponse<T> {
  final bool    success;
  final T?      data;
  final String? message;
  final String? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data:    data,
      message: message,
    );
  }

  factory ApiResponse.error(String error) {
    return ApiResponse(
      success: false,
      error:   error,
    );
  }

  bool get hasData  => data != null;
  bool get hasError => error != null && error!.isNotEmpty;
}