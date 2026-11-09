import '../../domain/entities/cow.dart';

CowPurpose mapPurpose(String value) => CowPurpose.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CowPurpose.milk,
    );

CowGender mapGender(String value) => CowGender.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CowGender.unknown,
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

String purposeToApi(CowPurpose value) => value.name;

String genderToApi(CowGender value) => value.name;

String acquiredByToApi(AcquisitionSource value) => switch (value) {
      AcquisitionSource.purchased => 'purchased',
      AcquisitionSource.bornOnFarm => 'born_on_farm',
    };

Cow mapCow(Map<String, dynamic> json) => Cow(
      id: json['id'] as String,
      tagNumber: json['tag_number'] as String,
      name: json['name'] as String?,
      breed: json['breed'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      purpose: mapPurpose(json['purpose'] as String),
      gender: mapGender(json['gender'] as String),
      color: json['color'] as String?,
      weight: json['weight']?.toString(),
      age: json['age'] as int?,
      acquiredBy: mapAcquiredBy(json['acquired_by'] as String),
      purchaseDate: json['purchase_date'] as String?,
      purchasePrice: json['purchase_price']?.toString(),
      notes: json['notes'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

MilkProduction mapMilk(Map<String, dynamic> json) => MilkProduction(
      id: json['id'] as String,
      cowId: json['cow_id'] as String,
      producedAt: json['produced_at'] as String,
      quantity: json['quantity'].toString(),
      unit: json['unit'] as String,
      pricePerUnit: json['price_per_unit'].toString(),
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
    );

CowFeeding mapFeeding(Map<String, dynamic> json) => CowFeeding(
      id: json['id'] as String,
      cowId: json['cow_id'] as String,
      fedAt: json['fed_at'] as String,
      feedName: json['feed_name'] as String,
      quantity: json['quantity'].toString(),
      unit: json['unit'] as String,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> cowWriteToJson(CowWriteParams params) => {
      'tag_number': params.tagNumber,
      'purpose': purposeToApi(params.purpose),
      'gender': genderToApi(params.gender),
      'acquired_by': acquiredByToApi(params.acquiredBy),
      'name': params.name,
      'breed': params.breed,
      'date_of_birth': params.dateOfBirth,
      'color': params.color,
      'weight': params.weight,
      'age': params.age,
      'purchase_date': params.acquiredBy == AcquisitionSource.purchased
          ? params.purchaseDate
          : null,
      'purchase_price': params.acquiredBy == AcquisitionSource.purchased
          ? params.purchasePrice
          : null,
      'notes': params.notes,
    };
