import 'package:mobile/data/models/poultry/egg_production_model.dart';
import 'package:mobile/data/models/poultry/poultry_feeding_model.dart';
import 'package:mobile/data/models/poultry/poultry_group_model.dart';
import 'package:mobile/domain/entities/common/acquisition_source.dart';
import 'package:mobile/domain/entities/poultry/egg_production.dart';
import 'package:mobile/domain/entities/poultry/poultry_feeding.dart';
import 'package:mobile/domain/entities/poultry/poultry_group.dart';
import 'package:mobile/domain/entities/poultry/poultry_group_write_params.dart';
import 'package:mobile/domain/entities/poultry/poultry_type.dart';

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

PoultryGroup mapPoultryGroup(Map<String, dynamic> json) =>
    mapPoultryGroupModel(PoultryGroupModel.fromJson(json));

PoultryGroup mapPoultryGroupModel(PoultryGroupModel model) => PoultryGroup(
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

EggProduction mapEgg(Map<String, dynamic> json) =>
    mapEggModel(EggProductionModel.fromJson(json));

EggProduction mapEggModel(EggProductionModel model) => EggProduction(
      id: model.id,
      poultryGroupId: model.poultryGroupId,
      producedAt: model.producedAt,
      quantity: model.quantity,
      unit: model.unit,
      pricePerUnit: model.pricePerUnit,
      note: model.note,
      createdAt: model.createdAt,
    );

PoultryFeeding mapPoultryFeeding(Map<String, dynamic> json) =>
    mapPoultryFeedingModel(PoultryFeedingModel.fromJson(json));

PoultryFeeding mapPoultryFeedingModel(PoultryFeedingModel model) =>
    PoultryFeeding(
      id: model.id,
      poultryGroupId: model.poultryGroupId,
      fedAt: model.fedAt,
      feedName: model.feedName,
      quantity: model.quantity,
      unit: model.unit,
      note: model.note,
      createdAt: model.createdAt,
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
