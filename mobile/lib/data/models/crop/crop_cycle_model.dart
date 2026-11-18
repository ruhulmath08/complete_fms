import 'package:mobile/data/models/common/json_parsers.dart';

class CropCycleModel {
  const CropCycleModel({
    required this.id,
    required this.cropNameId,
    required this.plantedAt,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.plotName,
    this.area,
    this.location,
    this.expectedHarvestAt,
    this.notes,
  });

  factory CropCycleModel.fromJson(Map<String, dynamic> json) => CropCycleModel(
        id: requireString(json['id'], 'id'),
        cropNameId: requireString(json['crop_name_id'], 'crop_name_id'),
        plotName: optionalString(json['plot_name']),
        area: optionalDecimalString(json['area']),
        location: optionalString(json['location']),
        plantedAt: requireString(json['planted_at'], 'planted_at'),
        expectedHarvestAt: optionalString(json['expected_harvest_at']),
        notes: optionalString(json['notes']),
        isArchived: requireBool(json['is_archived'], 'is_archived'),
        createdAt: requireString(json['created_at'], 'created_at'),
        updatedAt: requireString(json['updated_at'], 'updated_at'),
      );

  final String id;
  final String cropNameId;
  final String? plotName;
  final String? area;
  final String? location;
  final String plantedAt;
  final String? expectedHarvestAt;
  final String? notes;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'crop_name_id': cropNameId,
        'plot_name': plotName,
        'area': area,
        'location': location,
        'planted_at': plantedAt,
        'expected_harvest_at': expectedHarvestAt,
        'notes': notes,
        'is_archived': isArchived,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
