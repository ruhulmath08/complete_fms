import 'package:mobile/domain/entities/crop/expense_category.dart';

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
