import 'package:equatable/equatable.dart';

class FarmSettings extends Equatable {
  const FarmSettings({
    required this.id,
    required this.ownerId,
    required this.currencyCode,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String currencyCode;
  final String updatedAt;

  @override
  List<Object?> get props => [id, currencyCode, updatedAt];
}
