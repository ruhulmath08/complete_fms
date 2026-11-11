enum CowPurpose { milk, meat, both }

enum CowGender { female, male, unknown }

enum AcquisitionSource { purchased, bornOnFarm }

class Cow {
  const Cow({
    required this.id,
    required this.tagNumber,
    required this.purpose,
    required this.gender,
    required this.acquiredBy,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.breed,
    this.dateOfBirth,
    this.color,
    this.weight,
    this.age,
    this.purchaseDate,
    this.purchasePrice,
    this.notes,
    this.imageUrl,
  });

  final String id;
  final String tagNumber;
  final String? name;
  final String? breed;
  final String? dateOfBirth;
  final CowPurpose purpose;
  final CowGender gender;
  final String? color;
  final String? weight;
  final int? age;
  final AcquisitionSource acquiredBy;
  final String? purchaseDate;
  final String? purchasePrice;
  final String? notes;
  final String? imageUrl;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;

  bool get milkEligible =>
      purpose == CowPurpose.milk || purpose == CowPurpose.both;
}

class MilkProduction {
  const MilkProduction({
    required this.id,
    required this.cowId,
    required this.producedAt,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String cowId;
  final String producedAt;
  final String quantity;
  final String unit;
  final String pricePerUnit;
  final String? note;
  final String createdAt;
}

class CowFeeding {
  const CowFeeding({
    required this.id,
    required this.cowId,
    required this.fedAt,
    required this.feedName,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String cowId;
  final String fedAt;
  final String feedName;
  final String quantity;
  final String unit;
  final String? note;
  final String createdAt;
}

class PagedResult<T> {
  const PagedResult({
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

class CowWriteParams {
  const CowWriteParams({
    required this.purpose,
    required this.gender,
    required this.acquiredBy,
    required this.name,
    required this.breed,
    this.dateOfBirth,
    this.color,
    this.weight,
    this.age,
    this.purchaseDate,
    this.purchasePrice,
    this.notes,
  });

  final CowPurpose purpose;
  final CowGender gender;
  final AcquisitionSource acquiredBy;
  final String name;
  final String breed;
  final String? dateOfBirth;
  final String? color;
  final String? weight;
  final int? age;
  final String? purchaseDate;
  final String? purchasePrice;
  final String? notes;
}
