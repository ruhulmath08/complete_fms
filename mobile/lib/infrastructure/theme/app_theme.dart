import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Design tokens mirrored from web CSS where practical (`#2f6a3a`, neutrals, radius).
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.primary,
    required this.primaryHover,
    required this.background,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.border,
    required this.accent,
    required this.danger,
    required this.dangerBg,
    required this.radiusMd,
    required this.space1,
    required this.space2,
    required this.space3,
    required this.space4,
    required this.space5,
  });

  final Color primary;
  final Color primaryHover;
  final Color background;
  final Color surface;
  final Color ink;
  final Color muted;
  final Color border;
  final Color accent;
  final Color danger;
  final Color dangerBg;
  final double radiusMd;
  final double space1;
  final double space2;
  final double space3;
  final double space4;
  final double space5;

  static const light = AppTokens(
    primary: Color(0xFF2F6A3A),
    primaryHover: Color(0xFF25572F),
    background: Color(0xFFF3F6F1),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF1C2A1F),
    muted: Color(0xFF5B6B5E),
    border: Color(0xFFD5DDD4),
    accent: Color(0xFFC4A35A),
    danger: Color(0xFF9B2C2C),
    dangerBg: Color(0xFFFDECEC),
    radiusMd: 12,
    space1: 4,
    space2: 8,
    space3: 12,
    space4: 16,
    space5: 24,
  );

  static AppTokens of(BuildContext context) {
    return Theme.of(context).extension<AppTokens>() ?? AppTokens.light;
  }

  @override
  AppTokens copyWith({
    Color? primary,
    Color? primaryHover,
    Color? background,
    Color? surface,
    Color? ink,
    Color? muted,
    Color? border,
    Color? accent,
    Color? danger,
    Color? dangerBg,
    double? radiusMd,
    double? space1,
    double? space2,
    double? space3,
    double? space4,
    double? space5,
  }) {
    return AppTokens(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      danger: danger ?? this.danger,
      dangerBg: dangerBg ?? this.dangerBg,
      radiusMd: radiusMd ?? this.radiusMd,
      space1: space1 ?? this.space1,
      space2: space2 ?? this.space2,
      space3: space3 ?? this.space3,
      space4: space4 ?? this.space4,
      space5: space5 ?? this.space5,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerBg: Color.lerp(dangerBg, other.dangerBg, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      space1: lerpDouble(space1, other.space1, t)!,
      space2: lerpDouble(space2, other.space2, t)!,
      space3: lerpDouble(space3, other.space3, t)!,
      space4: lerpDouble(space4, other.space4, t)!,
      space5: lerpDouble(space5, other.space5, t)!,
    );
  }
}

class AppTheme {
  static const Color primary = Color(0xFF2F6A3A);
  static const Color background = Color(0xFFF3F6F1);
  static const Color ink = Color(0xFF1C2A1F);

  static ThemeData light() {
    const tokens = AppTokens.light;
    final base = ColorScheme.fromSeed(
      seedColor: tokens.primary,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      extensions: const [tokens],
      colorScheme: base.copyWith(
        primary: tokens.primary,
        surface: tokens.surface,
        onSurface: tokens.ink,
        outline: tokens.border,
        error: tokens.danger,
      ),
      scaffoldBackgroundColor: tokens.background,
      cardTheme: CardThemeData(
        color: tokens.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          side: BorderSide(color: tokens.border),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.background,
        foregroundColor: tokens.ink,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: tokens.space3 + 2,
            horizontal: tokens.space3 + 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}
