class PaginationResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;

  PaginationResult({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  int get totalPages => total == 0 ? 0 : (total / limit).ceil();

  bool get hasNextPage => page < totalPages;

  bool get hasPreviousPage => page > 1;

  Map<String, dynamic> toJson(
    Map<String, dynamic> Function(T item) serialize,
  ) {
    return {
      'items': items.map(serialize).toList(),
      'pagination': {
        'total': total,
        'page': page,
        'limit': limit,
        'totalPages': totalPages,
        'hasNextPage': hasNextPage,
        'hasPreviousPage': hasPreviousPage,
      },
    };
  }
}
