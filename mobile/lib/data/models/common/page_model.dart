import 'package:mobile/data/models/common/page_meta_model.dart';

class PageModel<T> {
  const PageModel({
    required this.items,
    required this.meta,
  });

  factory PageModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return PageModel(
      items: rawItems
          .map((e) => itemFromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PageMetaModel.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  final List<T> items;
  final PageMetaModel meta;

  Map<String, dynamic> toJson(Object? Function(T) itemToJson) => {
        'items': items.map(itemToJson).toList(),
        'meta': meta.toJson(),
      };
}
