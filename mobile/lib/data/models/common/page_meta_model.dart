import 'package:mobile/data/models/common/json_parsers.dart';

class PageMetaModel {
  const PageMetaModel({
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory PageMetaModel.fromJson(Map<String, dynamic> json) => PageMetaModel(
        total: requireInt(json['total'], 'total'),
        limit: requireInt(json['limit'], 'limit'),
        offset: requireInt(json['offset'], 'offset'),
      );

  final int total;
  final int limit;
  final int offset;

  Map<String, dynamic> toJson() => {
        'total': total,
        'limit': limit,
        'offset': offset,
      };
}
