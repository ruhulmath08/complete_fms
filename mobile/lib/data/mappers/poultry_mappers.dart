import '../../domain/entities/poultry.dart';

PoultryType mapPoultryType(String value) => PoultryType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PoultryType.layer,
    );

AcquisitionSource mapAcquiredBy(String value) {
  switch (value) {
    case 'purchased':
      return AcquisitionSource.purchased;
    case 'born_on_farm':
      return AcquisitionSource.bornOnFarm;
    default:
      return AcquisitionSource.bornOnFarm;
  }
}

String poultryTypeToApi(PoultryType value) => value.name;

String acquiredByToApi(AcquisitionSource value) => switch (value) {
      AcquisitionSource.purchased => 'purchased',
      AcquisitionSource.bornOnFarm => 'born_on_farm',
    };

PoultryGroup mapPoultryGroup(Map<String, dynamic> json) => PoultryGroup(
      id: json['id'] as String,
      poultryType: mapPoultryType(json['poultry_type'] as String),
      name: json['name'] as String,
      birdCount: json['bird_count'] as int,
      dateAcquired: json['date_acquired'] as String?,
      acquiredBy: mapAcquiredBy(json['acquired_by'] as String),
      purchaseDate: json['purchase_date'] as String?,
      purchasePrice: json['purchase_price']?.toString(),
      notes: json['notes'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

EggProduction mapEgg(Map<String, dynamic> json) => EggProduction(
      id: json['id'] as String,
      poultryGroupId: json['poultry_group_id'] as String,
      producedAt: json['produced_at'] as String,
      quantity: json['quantity'].toString(),
      unit: json['unit'] as String,
      pricePerUnit: json['price_per_unit'].toString(),
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
    );

PoultryFeeding mapPoultryFeeding(Map<String, dynamic> json) => PoultryFeeding(
      id: json['id'] as String,
      poultryGroupId: json['poultry_group_id'] as String,
      fedAt: json['fed_at'] as String,
      feedName: json['feed_name'] as String,
      quantity: json['quantity'].toString(),
      unit: json['unit'] as String,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> poultryGroupWriteToJson(PoultryGroupWriteParams params) => {
      'poultry_type': poultryTypeToApi(params.poultryType),
      'name': params.name,
      'bird_count': params.birdCount,
      'acquired_by': acquiredByToApi(params.acquiredBy),
      'date_acquired': params.dateAcquired,
      'purchase_date': params.acquiredBy == AcquisitionSource.purchased
          ? params.purchaseDate
          : null,
      'purchase_price': params.acquiredBy == AcquisitionSource.purchased
          ? params.purchasePrice
          : null,
      'notes': params.notes,
    };
