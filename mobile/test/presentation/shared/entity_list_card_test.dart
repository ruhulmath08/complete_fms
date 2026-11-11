import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/infrastructure/theme/app_theme.dart';
import 'package:mobile/presentation/shared/widgets/entity_list_card.dart';

void main() {
  testWidgets('EntityListCard shows title/subtitle and invokes onTap', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: EntityListCard(
            title: 'Tag-001 · Daisy',
            subtitle: 'milk · female',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Tag-001 · Daisy'), findsOneWidget);
    expect(find.text('milk · female'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);

    await tester.tap(find.byType(EntityListCard));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('EntityListCard uses AppTokens primary green centrally', (
    tester,
  ) async {
    late AppTokens tokens;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) {
            tokens = AppTokens.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(tokens.primary, const Color(0xFF2F6A3A));
    expect(tokens.border, const Color(0xFFD5DDD4));
    expect(tokens.radiusMd, 12);
  });
}
