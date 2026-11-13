import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/presentation/auth/widgets/profile_image_preview.dart';

import '../../support/pump_app.dart';

/// Minimal 1×1 PNG.
final Uint8List _tinyPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
  0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x00, 0x03, 0x00, 0x01, 0x00, 0x05, 0xFE, 0x02, 0xFE, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  testWidgets('shows full image with BoxFit.contain (not CircleAvatar crop)', (
    tester,
  ) async {
    await pumpLocalized(
      tester,
      ProfileImagePreview(bytes: _tinyPng),
    );

    expect(find.byType(CircleAvatar), findsNothing);
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.contain);
    expect(find.bySemanticsLabel('Profile image'), findsOneWidget);
  });

  testWidgets('renders nothing when no image source', (tester) async {
    await pumpLocalized(tester, const ProfileImagePreview());
    expect(find.byType(Image), findsNothing);
    expect(find.byType(CircleAvatar), findsNothing);
  });
}
