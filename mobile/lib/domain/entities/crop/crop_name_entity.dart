class CropNameEntity {
  const CropNameEntity({
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
