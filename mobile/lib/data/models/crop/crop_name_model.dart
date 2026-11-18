import 'package:mobile/data/models/common/json_parsers.dart';

class CropNameModel {
  const CropNameModel({
    required this.id,
    required this.name,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory CropNameModel.fromJson(Map<String, dynamic> json) => CropNameModel(
        id: requireString(json['id'], 'id'),
        name: requireString(json['name'], 'name'),
        notes: optionalString(json['notes']),
        isArchived: requireBool(json['is_archived'], 'is_archived'),
        createdAt: requireString(json['created_at'], 'created_at'),
        updatedAt: requireString(json['updated_at'], 'updated_at'),
      );

  final String id;
  final String name;
  final String? notes;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'notes': notes,
        'is_archived': isArchived,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
