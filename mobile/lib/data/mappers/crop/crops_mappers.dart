import 'package:mobile/data/models/crop/crop_cycle_model.dart';
import 'package:mobile/data/models/crop/crop_expense_model.dart';
import 'package:mobile/data/models/crop/crop_name_model.dart';
import 'package:mobile/data/models/crop/cycle_summary_model.dart';
import 'package:mobile/data/models/crop/harvest_model.dart';
import 'package:mobile/domain/entities/crop/crop_cycle.dart';
import 'package:mobile/domain/entities/crop/crop_cycle_write_params.dart';
import 'package:mobile/domain/entities/crop/crop_expense.dart';
import 'package:mobile/domain/entities/crop/crop_name.dart';
import 'package:mobile/domain/entities/crop/crop_name_write_params.dart';
import 'package:mobile/domain/entities/crop/cycle_summary.dart';
import 'package:mobile/domain/entities/crop/expense_category.dart';
import 'package:mobile/domain/entities/crop/harvest.dart';

ExpenseCategory mapExpenseCategory(String value) {
  switch (value) {
    case 'labour':
      return ExpenseCategory.labour;
    case 'fertilizers':
      return ExpenseCategory.fertilizers;
    case 'pesticides_and_chemicals':
      return ExpenseCategory.pesticidesAndChemicals;
    case 'seeds':
      return ExpenseCategory.seeds;
    case 'irrigation':
      return ExpenseCategory.irrigation;
    case 'equipment':
      return ExpenseCategory.equipment;
    case 'other':
      return ExpenseCategory.other;
    default:
      return ExpenseCategory.other;
  }
}

String expenseCategoryToApi(ExpenseCategory value) => switch (value) {
      ExpenseCategory.labour => 'labour',
      ExpenseCategory.fertilizers => 'fertilizers',
      ExpenseCategory.pesticidesAndChemicals => 'pesticides_and_chemicals',
      ExpenseCategory.seeds => 'seeds',
      ExpenseCategory.irrigation => 'irrigation',
      ExpenseCategory.equipment => 'equipment',
      ExpenseCategory.other => 'other',
    };

CropName mapCropName(Map<String, dynamic> json) =>
    mapCropNameModel(CropNameModel.fromJson(json));

CropName mapCropNameModel(CropNameModel model) => CropName(
      id: model.id,
      name: model.name,
      notes: model.notes,
      isArchived: model.isArchived,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );

CropCycle mapCropCycle(Map<String, dynamic> json) =>
    mapCropCycleModel(CropCycleModel.fromJson(json));

CropCycle mapCropCycleModel(CropCycleModel model) => CropCycle(
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

CropExpense mapCropExpense(Map<String, dynamic> json) =>
    mapCropExpenseModel(CropExpenseModel.fromJson(json));

CropExpense mapCropExpenseModel(CropExpenseModel model) => CropExpense(
      id: model.id,
      cropCycleId: model.cropCycleId,
      spentAt: model.spentAt,
      category: mapExpenseCategory(model.category),
      amount: model.amount,
      note: model.note,
      createdAt: model.createdAt,
    );

Harvest mapHarvest(Map<String, dynamic> json) =>
    mapHarvestModel(HarvestModel.fromJson(json));

Harvest mapHarvestModel(HarvestModel model) => Harvest(
      id: model.id,
      cropCycleId: model.cropCycleId,
      harvestedAt: model.harvestedAt,
      quantity: model.quantity,
      unit: model.unit,
      saleAmount: model.saleAmount,
      note: model.note,
      createdAt: model.createdAt,
    );

CycleSummary mapCycleSummary(Map<String, dynamic> json) =>
    mapCycleSummaryModel(CycleSummaryModel.fromJson(json));

CycleSummary mapCycleSummaryModel(CycleSummaryModel model) => CycleSummary(
      cropCycleId: model.cropCycleId,
      totalExpenses: model.totalExpenses,
      totalSaleIncome: model.totalSaleIncome,
      result: model.result,
    );

Map<String, dynamic> cropNameWriteToJson(CropNameWriteParams params) => {
      'name': params.name,
      'notes': params.notes,
    };

Map<String, dynamic> cropCycleWriteToJson(CropCycleWriteParams params) => {
      'crop_name_id': params.cropNameId,
      'planted_at': params.plantedAt,
      'plot_name': params.plotName,
      'area': params.area,
      'location': params.location,
      'expected_harvest_at': params.expectedHarvestAt,
      'notes': params.notes,
    };
