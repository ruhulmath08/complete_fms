import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/mappers/auth_mappers.dart';

void main() {
  test('maps owner profile JSON from API', () {
    final profile = mapOwnerProfile({
      'id': '11111111-1111-1111-1111-111111111111',
      'full_name': 'Farm Owner',
      'email': 'owner@example.com',
      'phone': '+8801711111111',
      'address': 'Dhaka',
      'latitude': 23.81,
      'longitude': 90.41,
      'profile_image_url': '/api/v1/me/profile-image',
      'updated_at': '2026-11-09T09:00:00Z',
      'created_at': '2026-11-09T08:00:00Z',
    });

    expect(profile.email, 'owner@example.com');
    expect(profile.fullName, 'Farm Owner');
    expect(profile.latitude, 23.81);
  });

  test('maps farm settings and tokens', () {
    final settings = mapFarmSettings({
      'id': '22222222-2222-2222-2222-222222222222',
      'owner_id': '11111111-1111-1111-1111-111111111111',
      'currency_code': 'BDT',
      'updated_at': '2026-11-09T09:00:00Z',
      'created_at': '2026-11-09T08:00:00Z',
    });
    final tokens = mapTokens({
      'access_token': 'a',
      'refresh_token': 'r',
      'token_type': 'bearer',
      'expires_in': 900,
    });

    expect(settings.currencyCode, 'BDT');
    expect(tokens.expiresIn, 900);
    expect(tokens.accessToken, 'a');
  });
}
