import 'base_response.dart';

class PaginatedResponse<T> extends BaseResponse<List<T>> {
  final int currentPage;
  final int totalPages;
  final int perPage;
  final int totalItems;

  const PaginatedResponse({
    required super.success,
    required super.message,
    required super.data,
    required this.currentPage,
    required this.totalPages,
    required this.perPage,
    required this.totalItems,
    super.errorCode,
    required super.timestamp,
  });

  bool get hasNext => currentPage < totalPages;
  bool get hasPrev => currentPage > 1;
}
