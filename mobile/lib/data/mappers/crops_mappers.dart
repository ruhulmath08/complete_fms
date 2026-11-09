import '../../domain/entities/crop.dart';

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

CropName mapCropName(Map<String, dynamic> json) => CropName(
      id: json['id'] as String,
      name: json['name'] as String,
      notes: json['notes'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

CropCycle mapCropCycle(Map<String, dynamic> json) => CropCycle(
      id: json['id'] as String,
      cropNameId: json['crop_name_id'] as String,
      plotName: json['plot_name'] as String?,
      area: json['area']?.toString(),
      location: json['location'] as String?,
      plantedAt: json['planted_at'] as String,
      expectedHarvestAt: json['expected_harvest_at'] as String?,
      notes: json['notes'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

CropExpense mapCropExpense(Map<String, dynamic> json) => CropExpense(
      id: json['id'] as String,
      cropCycleId: json['crop_cycle_id'] as String,
      spentAt: json['spent_at'] as String,
      category: mapExpenseCategory(json['category'] as String),
      amount: json['amount'].toString(),
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
    );

Harvest mapHarvest(Map<String, dynamic> json) => Harvest(
      id: json['id'] as String,
      cropCycleId: json['crop_cycle_id'] as String,
      harvestedAt: json['harvested_at'] as String,
      quantity: json['quantity'].toString(),
      unit: json['unit'] as String,
      saleAmount: json['sale_amount']?.toString(),
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
    );

CycleSummary mapCycleSummary(Map<String, dynamic> json) => CycleSummary(
      cropCycleId: json['crop_cycle_id'] as String,
      totalExpenses: json['total_expenses'].toString(),
      totalSaleIncome: json['total_sale_income'].toString(),
      result: json['result'].toString(),
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
