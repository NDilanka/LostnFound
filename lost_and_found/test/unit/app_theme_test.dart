import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lost_and_found/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  group('AppTheme color constants', () {
    test('primary color is amber-600', () {
      expect(AppTheme.primary, const Color(0xFFD97706));
    });

    test('lostBadge color is orange-600', () {
      expect(AppTheme.lostBadge, const Color(0xFFEA580C));
    });

    test('foundBadge color is green-600', () {
      expect(AppTheme.foundBadge, const Color(0xFF16A34A));
    });

    test('background is warm cream', () {
      expect(AppTheme.background, const Color(0xFFFFFBEB));
    });

    test('error color is red', () {
      expect(AppTheme.error, const Color(0xFFDC2626));
    });
  });

  group('AppTheme.badgeDecoration', () {
    test('returns lostBadge color for "lost" type', () {
      final decoration = AppTheme.badgeDecoration('lost');
      expect(decoration.color, AppTheme.lostBadge);
      expect(decoration.borderRadius, AppTheme.radiusSmall);
    });

    test('returns foundBadge color for "found" type', () {
      final decoration = AppTheme.badgeDecoration('found');
      expect(decoration.color, AppTheme.foundBadge);
      expect(decoration.borderRadius, AppTheme.radiusSmall);
    });

    test('defaults to foundBadge for unknown type', () {
      final decoration = AppTheme.badgeDecoration('other');
      expect(decoration.color, AppTheme.foundBadge);
    });
  });

  group('AppTheme.badgeTextStyle', () {
    test('has white color', () {
      expect(AppTheme.badgeTextStyle.color, AppTheme.onPrimary);
    });

    test('has fontSize 12', () {
      expect(AppTheme.badgeTextStyle.fontSize, 12);
    });

    test('has fontWeight w600', () {
      expect(AppTheme.badgeTextStyle.fontWeight, FontWeight.w600);
    });
  });

  // themeData() tests require google_fonts which needs bundled font files
  // in test environment. Tested via E2E instead.

  group('AppTheme spacing constants', () {
    test('follow 4dp base system', () {
      expect(AppTheme.space4, 4);
      expect(AppTheme.space8, 8);
      expect(AppTheme.space12, 12);
      expect(AppTheme.space16, 16);
      expect(AppTheme.space24, 24);
      expect(AppTheme.space32, 32);
      expect(AppTheme.space48, 48);
    });
  });

  group('AppTheme border radius', () {
    test('radiusSmall is 6dp', () {
      expect(AppTheme.radiusSmall, BorderRadius.circular(6));
    });

    test('radiusMedium is 12dp', () {
      expect(AppTheme.radiusMedium, BorderRadius.circular(12));
    });
  });
}
