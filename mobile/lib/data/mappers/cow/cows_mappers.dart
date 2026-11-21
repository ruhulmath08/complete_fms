import 'package:mobile/data/models/cow/cow_feeding_model.dart';
import 'package:mobile/data/models/cow/cow_model.dart';
import 'package:mobile/data/models/cow/milk_production_model.dart';
import 'package:mobile/domain/entities/common/acquisition_source_entity.dart';
import 'package:mobile/domain/entities/cow/cow_entity.dart';
import 'package:mobile/domain/entities/cow/cow_feeding_entity.dart';
import 'package:mobile/domain/entities/cow/cow_gender_entity.dart';
import 'package:mobile/domain/entities/cow/cow_purpose_entity.dart';
import 'package:mobile/domain/entities/cow/cow_write_params_entity.dart';
import 'package:mobile/domain/entities/cow/milk_production_entity.dart';

CowPurposeEntity mapPurpose(String value) => CowPurposeEntity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CowPurposeEntity.milk,
    );

CowGenderEntity mapGender(String value) => CowGenderEntity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CowGenderEntity.unknown,
    );

AcquisitionSourceEntity mapAcquiredBy(String value) {
  switch (value) {
    case 'purchased':
      return AcquisitionSourceEntity.purchased;
    case 'born_on_farm':
      return AcquisitionSourceEntity.bornOnFarm;
    default:
      return AcquisitionSourceEntity.bornOnFarm;
  }
}

String purposeToApi(CowPurposeEntity value) => value.name;

String genderToApi(CowGenderEntity value) => value.name;

String acquiredByToApi(AcquisitionSourceEntity value) => switch (value) {
      AcquisitionSourceEntity.purchased => 'purchased',
      AcquisitionSourceEntity.bornOnFarm => 'born_on_farm',
    };

CowEntity mapCow(Map<String, dynamic> json) => mapCowModel(CowModel.fromJson(json));

CowEntity mapCowModel(CowModel model) => CowEntity(
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

MilkProductionEntity mapMilk(Map<String, dynamic> json) =>
    mapMilkModel(MilkProductionModel.fromJson(json));

MilkProductionEntity mapMilkModel(MilkProductionModel model) => MilkProductionEntity(
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

CowFeedingEntity mapFeeding(Map<String, dynamic> json) =>
    mapFeedingModel(CowFeedingModel.fromJson(json));

CowFeedingEntity mapFeedingModel(CowFeedingModel model) => CowFeedingEntity(
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

Map<String, dynamic> cowWriteToJson(CowWriteParamsEntity params) => {
      'purpose': purposeToApi(params.purpose),
      'gender': genderToApi(params.gender),
      'acquired_by': acquiredByToApi(params.acquiredBy),
      'name': params.name,
      'breed': params.breed,
      'date_of_birth': params.dateOfBirth,
      'color': params.color,
      'weight': params.weight,
      'age': params.age,
      'purchase_date': params.acquiredBy == AcquisitionSourceEntity.purchased
          ? params.purchaseDate
          : null,
      'purchase_price': params.acquiredBy == AcquisitionSourceEntity.purchased
          ? params.purchasePrice
          : null,
      'notes': params.notes,
    };
