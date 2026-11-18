import 'package:mobile/data/models/common/json_parsers.dart';

class FarmSettingsModel {
  const FarmSettingsModel({
    required this.id,
    required this.ownerId,
    required this.currencyCode,
    required this.updatedAt,
    this.timezone,
    this.createdAt,
  });

  factory FarmSettingsModel.fromJson(Map<String, dynamic> json) =>
      FarmSettingsModel(
        id: requireString(json['id'], 'id'),
        ownerId: requireString(json['owner_id'], 'owner_id'),
        currencyCode: requireString(json['currency_code'], 'currency_code'),
        timezone: optionalString(json['timezone']),
        createdAt: optionalString(json['created_at']),
        updatedAt: requireString(json['updated_at'], 'updated_at'),
      );

  final String id;
  final String ownerId;
  final String currencyCode;
  final String? timezone;
  final String? createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': ownerId,
        'currency_code': currencyCode,
        if (timezone != null) 'timezone': timezone,
        if (createdAt != null) 'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
