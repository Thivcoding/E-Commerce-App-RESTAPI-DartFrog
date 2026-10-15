class ProductQuery {
  final int page;
  final int limit;
  final String? search;
  final String? categoryId;

  ProductQuery({
    required this.page,
    required this.limit,
    this.search,
    this.categoryId,
  });

  factory ProductQuery.fromQueryParameters(
    Map<String, String> queryParameters,
  ) {
    final pageValue = queryParameters['page'];
    final limitValue = queryParameters['limit'];

    final page = int.tryParse(pageValue ?? '') ?? 1;
    final limit = int.tryParse(limitValue ?? '') ?? 10;

    return ProductQuery(
      page: page < 1 ? 1 : page,
      limit: limit < 1
          ? 10
          : limit > 100
          ? 100
          : limit,
      search: queryParameters['search']?.trim(),
      categoryId: queryParameters['categoryId']?.trim(),
    );
  }

  int get skip => (page - 1) * limit;
}
