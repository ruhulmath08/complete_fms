class PagedResultEntity<T> {
  const PagedResultEntity({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  final List<T> items;
  final int total;
  final int limit;
  final int offset;
}
