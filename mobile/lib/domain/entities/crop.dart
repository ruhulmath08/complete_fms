export 'cow.dart' show PagedResult;

enum ExpenseCategory {
  labour,
  fertilizers,
  pesticidesAndChemicals,
  seeds,
  irrigation,
  equipment,
  other,
}

class CropName {
  const CropName({
    required this.id,
    required this.name,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  final String id;
  final String name;
  final String? notes;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;
}

class CropCycle {
  const CropCycle({
    required this.id,
    required this.cropNameId,
    required this.plantedAt,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.plotName,
    this.area,
    this.location,
    this.expectedHarvestAt,
    this.notes,
  });

  final String id;
  final String cropNameId;
  final String? plotName;
  final String? area;
  final String? location;
  final String plantedAt;
  final String? expectedHarvestAt;
  final String? notes;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;
}

class CropExpense {
  const CropExpense({
    required this.id,
    required this.cropCycleId,
    required this.spentAt,
    required this.category,
    required this.amount,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String cropCycleId;
  final String spentAt;
  final ExpenseCategory category;
  final String amount;
  final String? note;
  final String createdAt;
}

class Harvest {
  const Harvest({
    required this.id,
    required this.cropCycleId,
    required this.harvestedAt,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    this.saleAmount,
    this.note,
  });

  final String id;
  final String cropCycleId;
  final String harvestedAt;
  final String quantity;
  final String unit;
  final String? saleAmount;
  final String? note;
  final String createdAt;
}

class CycleSummary {
  const CycleSummary({
    required this.cropCycleId,
    required this.totalExpenses,
    required this.totalSaleIncome,
    required this.result,
  });

  final String cropCycleId;
  final String totalExpenses;
  final String totalSaleIncome;
  final String result;
}

class CropNameWriteParams {
  const CropNameWriteParams({
    required this.name,
    this.notes,
  });

  final String name;
  final String? notes;
}

class CropCycleWriteParams {
  const CropCycleWriteParams({
    required this.cropNameId,
    required this.plantedAt,
    this.plotName,
    this.area,
    this.location,
    this.expectedHarvestAt,
    this.notes,
  });

  final String cropNameId;
  final String plantedAt;
  final String? plotName;
  final String? area;
  final String? location;
  final String? expectedHarvestAt;
  final String? notes;
}
