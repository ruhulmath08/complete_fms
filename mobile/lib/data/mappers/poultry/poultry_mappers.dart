import 'package:mobile/data/models/poultry/egg_production_model.dart';
import 'package:mobile/data/models/poultry/poultry_feeding_model.dart';
import 'package:mobile/data/models/poultry/poultry_group_model.dart';
import 'package:mobile/domain/entities/common/acquisition_source_entity.dart';
import 'package:mobile/domain/entities/poultry/egg_production_entity.dart';
import 'package:mobile/domain/entities/poultry/poultry_feeding_entity.dart';
import 'package:mobile/domain/entities/poultry/poultry_group_entity.dart';
import 'package:mobile/domain/entities/poultry/poultry_group_write_params_entity.dart';
import 'package:mobile/domain/entities/poultry/poultry_type_entity.dart';

PoultryTypeEntity mapPoultryType(String value) => PoultryTypeEntity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PoultryTypeEntity.layer,
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

String poultryTypeToApi(PoultryTypeEntity value) => value.name;

String acquiredByToApi(AcquisitionSourceEntity value) => switch (value) {
      AcquisitionSourceEntity.purchased => 'purchased',
      AcquisitionSourceEntity.bornOnFarm => 'born_on_farm',
    };

PoultryGroupEntity mapPoultryGroup(Map<String, dynamic> json) =>
    mapPoultryGroupModel(PoultryGroupModel.fromJson(json));

PoultryGroupEntity mapPoultryGroupModel(PoultryGroupModel model) => PoultryGroupEntity(
      id: model.id,
      poultryType: mapPoultryType(model.poultryType),
      name: model.name,
      birdCount: model.birdCount,
      dateAcquired: model.dateAcquired,
      acquiredBy: mapAcquiredBy(model.acquiredBy),
      purchaseDate: model.purchaseDate,
      purchasePrice: model.purchasePrice,
      notes: model.notes,
      isArchived: model.isArchived,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );

EggProductionEntity mapEgg(Map<String, dynamic> json) =>
    mapEggModel(EggProductionModel.fromJson(json));

EggProductionEntity mapEggModel(EggProductionModel model) => EggProductionEntity(
      id: model.id,
      poultryGroupId: model.poultryGroupId,
      producedAt: model.producedAt,
      quantity: model.quantity,
      unit: model.unit,
      pricePerUnit: model.pricePerUnit,
      note: model.note,
      createdAt: model.createdAt,
    );

PoultryFeedingEntity mapPoultryFeeding(Map<String, dynamic> json) =>
    mapPoultryFeedingModel(PoultryFeedingModel.fromJson(json));

PoultryFeedingEntity mapPoultryFeedingModel(PoultryFeedingModel model) =>
    PoultryFeedingEntity(
      id: model.id,
      poultryGroupId: model.poultryGroupId,
      fedAt: model.fedAt,
      feedName: model.feedName,
      quantity: model.quantity,
      unit: model.unit,
      note: model.note,
      createdAt: model.createdAt,
    );

Map<String, dynamic> poultryGroupWriteToJson(PoultryGroupWriteParamsEntity params) => {
      'poultry_type': poultryTypeToApi(params.poultryType),
      'name': params.name,
      'bird_count': params.birdCount,
      'acquired_by': acquiredByToApi(params.acquiredBy),
      'date_acquired': params.dateAcquired,
      'purchase_date': params.acquiredBy == AcquisitionSourceEntity.purchased
          ? params.purchaseDate
          : null,
      'purchase_price': params.acquiredBy == AcquisitionSourceEntity.purchased
          ? params.purchasePrice
          : null,
      'notes': params.notes,
    };
