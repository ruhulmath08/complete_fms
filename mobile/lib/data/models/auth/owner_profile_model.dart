import 'package:mobile/data/models/common/json_parsers.dart';

class OwnerProfileModel {
  const OwnerProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.profileImageUrl,
    required this.updatedAt,
    this.createdAt,
  });

  factory OwnerProfileModel.fromJson(Map<String, dynamic> json) =>
      OwnerProfileModel(
        id: requireString(json['id'], 'id'),
        fullName: requireString(json['full_name'], 'full_name'),
        email: requireString(json['email'], 'email'),
        phone: requireString(json['phone'], 'phone'),
        address: requireString(json['address'], 'address'),
        latitude: requireDouble(json['latitude'], 'latitude'),
        longitude: requireDouble(json['longitude'], 'longitude'),
        profileImageUrl:
            requireString(json['profile_image_url'], 'profile_image_url'),
        createdAt: optionalString(json['created_at']),
        updatedAt: requireString(json['updated_at'], 'updated_at'),
      );

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final String profileImageUrl;
  final String? createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'profile_image_url': profileImageUrl,
        if (createdAt != null) 'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
