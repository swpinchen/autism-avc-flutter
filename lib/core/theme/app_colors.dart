import 'dart:ui';

/// Figma design-token palette for AVC Calendar.
///
/// Extracted from the "Colors" frame (node 1737:3528) of the
/// AVC-Calendar-Designs Figma file.
abstract final class AppColors {
  // ── Primary blue ──────────────────────────────────────────────────────────
  static const primaryBlueLighter30 = Color(0xFFF4F3FF);
  static const primaryBlueLighter20 = Color(0xFFE1DFFF);
  static const primaryBlueLighter10 = Color(0xFF9D99D4);
  static const primaryBlueBase = Color(0xFF7571AB);
  static const primaryBlueDarker10 = Color(0xFF4B477C);

  // ── Blossom pink ──────────────────────────────────────────────────────────
  static const blossomPinkLighter30 = Color(0xFFFFE7F5);
  static const blossomPinkLighter20 = Color(0xFFFFD7EF);
  static const blossomPinkLighter10 = Color(0xFFFFB0DF);
  static const blossomPinkBase = Color(0xFFF475C1);
  static const blossomPinkDarker10 = Color(0xFFDE369B);

  // ── Brilliant teal ────────────────────────────────────────────────────────
  static const brilliantTealLighter30 = Color(0xFFE0F7F7);
  static const brilliantTealLighter20 = Color(0xFFB2EBEB);
  static const brilliantTealLighter10 = Color(0xFF7ABFBF);
  static const brilliantTealBase = Color(0xFF4FA3A3);
  static const brilliantTealDarker10 = Color(0xFF2E7D7D);

  // ── Neutral gray ──────────────────────────────────────────────────────────
  static const neutralGrayLighter30 = Color(0xFFF8F8F8);
  static const neutralGrayLighter20 = Color(0xFFEFEFEF);
  static const neutralGrayLighter10 = Color(0xFFDFDFDF);
  static const neutralGrayBase = Color(0xFFCACACA);
  static const neutralGrayDarker10 = Color(0xFF9D9D9D);
  static const neutralGrayDarker20 = Color(0xFF6F6F6F);
  static const neutralGrayDarker30 = Color(0xFF303030);

  // ── Contextual: brick red – danger ────────────────────────────────────────
  static const brickRedLighter20 = Color(0xFFFFC7C7);
  static const brickRedLighter10 = Color(0xFFE88B8B);
  static const brickRedBase = Color(0xFFD25A5A);
  static const brickRedDarker10 = Color(0xFFA82020);

  // ── Contextual: forest green – success ────────────────────────────────────
  static const forestGreenLighter20 = Color(0xFFD5F0D5);
  static const forestGreenLighter10 = Color(0xFF8BC8A4);
  static const forestGreenBase = Color(0xFF5BA87A);
  static const forestGreenDarker10 = Color(0xFF2E7D56);

  // ── Contextual: sunshine yellow – warning ─────────────────────────────────
  static const sunshineYellowLighter20 = Color(0xFFFFF3CC);
  static const sunshineYellowLighter10 = Color(0xFFFFE494);
  static const sunshineYellowBase = Color(0xFFFFD54F);
  static const sunshineYellowDarker10 = Color(0xFFF5C623);

  // ── Highlight glow (used by ChildScreen card tap) ─────────────────────────
  static const highlightPink = Color(0xFFFF8EBE);
}
