class PaginatedResponse<T> {
  final bool success;
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
  final bool hasMore;
  final List<T> data;

  PaginatedResponse({
    required this.success,
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
    required this.hasMore,
    required this.data,
  });
}
