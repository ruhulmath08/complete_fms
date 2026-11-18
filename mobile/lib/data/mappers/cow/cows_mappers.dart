import 'package:mobile/data/models/cow/cow_feeding_model.dart';
import 'package:mobile/data/models/cow/cow_model.dart';
import 'package:mobile/data/models/cow/milk_production_model.dart';
import 'package:mobile/domain/entities/common/acquisition_source.dart';
import 'package:mobile/domain/entities/cow/cow.dart';
import 'package:mobile/domain/entities/cow/cow_feeding.dart';
import 'package:mobile/domain/entities/cow/cow_gender.dart';
import 'package:mobile/domain/entities/cow/cow_purpose.dart';
import 'package:mobile/domain/entities/cow/cow_write_params.dart';
import 'package:mobile/domain/entities/cow/milk_production.dart';

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

Cow mapCow(Map<String, dynamic> json) => mapCowModel(CowModel.fromJson(json));

Cow mapCowModel(CowModel model) => Cow(
      id: model.id,
      tagNumber: model.tagNumber,
      name: model.name,
      breed: model.breed,
      dateOfBirth: model.dateOfBirth,
      purpose: mapPurpose(model.purpose),
      gender: mapGender(model.gender),
      color: model.color,
      weight: model.weight,
      age: model.age,
      acquiredBy: mapAcquiredBy(model.acquiredBy),
      purchaseDate: model.purchaseDate,
      purchasePrice: model.purchasePrice,
      notes: model.notes,
      imageUrl: model.imageUrl,
      isArchived: model.isArchived,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );

MilkProduction mapMilk(Map<String, dynamic> json) =>
    mapMilkModel(MilkProductionModel.fromJson(json));

MilkProduction mapMilkModel(MilkProductionModel model) => MilkProduction(
      id: model.id,
      cowId: model.cowId,
      producedAt: model.producedAt,
      quantity: model.quantity,
      unit: model.unit,
      pricePerUnit: model.pricePerUnit,
      note: model.note,
      createdAt: model.createdAt,
      total: model.total,
    );

CowFeeding mapFeeding(Map<String, dynamic> json) =>
    mapFeedingModel(CowFeedingModel.fromJson(json));

CowFeeding mapFeedingModel(CowFeedingModel model) => CowFeeding(
      id: model.id,
      cowId: model.cowId,
      fedAt: model.fedAt,
      feedName: model.feedName,
      quantity: model.quantity,
      unit: model.unit,
      unitCost: model.unitCost,
      note: model.note,
      createdAt: model.createdAt,
      total: model.total,
    );

Map<String, dynamic> cowWriteToJson(CowWriteParams params) => {
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
