import 'package:mobile/data/models/crop/crop_cycle_model.dart';
import 'package:mobile/data/models/crop/crop_expense_model.dart';
import 'package:mobile/data/models/crop/crop_name_model.dart';
import 'package:mobile/data/models/crop/cycle_summary_model.dart';
import 'package:mobile/data/models/crop/harvest_model.dart';
import 'package:mobile/domain/entities/crop/crop_cycle_entity.dart';
import 'package:mobile/domain/entities/crop/crop_cycle_write_params_entity.dart';
import 'package:mobile/domain/entities/crop/crop_expense_entity.dart';
import 'package:mobile/domain/entities/crop/crop_name_entity.dart';
import 'package:mobile/domain/entities/crop/crop_name_write_params_entity.dart';
import 'package:mobile/domain/entities/crop/cycle_summary_entity.dart';
import 'package:mobile/domain/entities/crop/expense_category_entity.dart';
import 'package:mobile/domain/entities/crop/harvest_entity.dart';

ExpenseCategoryEntity mapExpenseCategory(String value) {
  switch (value) {
    case 'labour':
      return ExpenseCategoryEntity.labour;
    case 'fertilizers':
      return ExpenseCategoryEntity.fertilizers;
    case 'pesticides_and_chemicals':
      return ExpenseCategoryEntity.pesticidesAndChemicals;
    case 'seeds':
      return ExpenseCategoryEntity.seeds;
    case 'irrigation':
      return ExpenseCategoryEntity.irrigation;
    case 'equipment':
      return ExpenseCategoryEntity.equipment;
    case 'other':
      return ExpenseCategoryEntity.other;
    default:
      return ExpenseCategoryEntity.other;
  }
}

String expenseCategoryToApi(ExpenseCategoryEntity value) => switch (value) {
      ExpenseCategoryEntity.labour => 'labour',
      ExpenseCategoryEntity.fertilizers => 'fertilizers',
      ExpenseCategoryEntity.pesticidesAndChemicals => 'pesticides_and_chemicals',
      ExpenseCategoryEntity.seeds => 'seeds',
      ExpenseCategoryEntity.irrigation => 'irrigation',
      ExpenseCategoryEntity.equipment => 'equipment',
      ExpenseCategoryEntity.other => 'other',
    };

CropNameEntity mapCropName(Map<String, dynamic> json) =>
    mapCropNameModel(CropNameModel.fromJson(json));

CropNameEntity mapCropNameModel(CropNameModel model) => CropNameEntity(
      id: model.id,
      name: model.name,
      notes: model.notes,
      isArchived: model.isArchived,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );

CropCycleEntity mapCropCycle(Map<String, dynamic> json) =>
    mapCropCycleModel(CropCycleModel.fromJson(json));

CropCycleEntity mapCropCycleModel(CropCycleModel model) => CropCycleEntity(
      id: model.id,
      cropNameId: model.cropNameId,
      plotName: model.plotName,
      area: model.area,
      location: model.location,
      plantedAt: model.plantedAt,
      expectedHarvestAt: model.expectedHarvestAt,
      notes: model.notes,
      isArchived: model.isArchived,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );

CropExpenseEntity mapCropExpense(Map<String, dynamic> json) =>
    mapCropExpenseModel(CropExpenseModel.fromJson(json));

CropExpenseEntity mapCropExpenseModel(CropExpenseModel model) => CropExpenseEntity(
      id: model.id,
      cropCycleId: model.cropCycleId,
      spentAt: model.spentAt,
      category: mapExpenseCategory(model.category),
      amount: model.amount,
      note: model.note,
      createdAt: model.createdAt,
    );

HarvestEntity mapHarvest(Map<String, dynamic> json) =>
    mapHarvestModel(HarvestModel.fromJson(json));

HarvestEntity mapHarvestModel(HarvestModel model) => HarvestEntity(
      id: model.id,
      cropCycleId: model.cropCycleId,
      harvestedAt: model.harvestedAt,
      quantity: model.quantity,
      unit: model.unit,
      saleAmount: model.saleAmount,
      note: model.note,
      createdAt: model.createdAt,
    );

CycleSummaryEntity mapCycleSummary(Map<String, dynamic> json) =>
    mapCycleSummaryModel(CycleSummaryModel.fromJson(json));

CycleSummaryEntity mapCycleSummaryModel(CycleSummaryModel model) => CycleSummaryEntity(
      cropCycleId: model.cropCycleId,
      totalExpenses: model.totalExpenses,
      totalSaleIncome: model.totalSaleIncome,
      result: model.result,
    );

Map<String, dynamic> cropNameWriteToJson(CropNameWriteParamsEntity params) => {
      'name': params.name,
      'notes': params.notes,
    };

Map<String, dynamic> cropCycleWriteToJson(CropCycleWriteParamsEntity params) => {
      'crop_name_id': params.cropNameId,
      'planted_at': params.plantedAt,
      'plot_name': params.plotName,
      'area': params.area,
      'location': params.location,
      'expected_harvest_at': params.expectedHarvestAt,
      'notes': params.notes,
    };
