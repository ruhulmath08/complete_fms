import 'package:equatable/equatable.dart';

class OwnerProfile extends Equatable {
  const OwnerProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.profileImageUrl,
    required this.updatedAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final String profileImageUrl;
  final String updatedAt;

  @override
  List<Object?> get props => [id, email, phone, updatedAt];
}
