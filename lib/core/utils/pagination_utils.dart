class PaginationUtils {
  const PaginationUtils._();

  static bool hasMore({
    required int currentPage,
    required int currentLimit,
    required int totalItems,
    required int totalPages,
  }) {
    // Prefer totalPages if available
    if (totalPages > 0) {
      return currentPage < totalPages;
    }

    // Fallback calculation
    return (currentPage * currentLimit) < totalItems;
  }
}
