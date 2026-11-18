import 'package:mobile/data/models/common/page_model.dart';
import 'package:mobile/domain/entities/common/paged_result.dart';

/// Maps a paged API payload through a data [Model] into a domain [PagedResult].
PagedResult<T> mapPageResult<T, M>(
  Map<String, dynamic> json,
  M Function(Map<String, dynamic>) fromJson,
  T Function(M) toEntity,
) {
  final page = PageModel.fromJson(json, fromJson);
  return PagedResult(
    items: page.items.map(toEntity).toList(),
    total: page.meta.total,
    limit: page.meta.limit,
    offset: page.meta.offset,
  );
}
