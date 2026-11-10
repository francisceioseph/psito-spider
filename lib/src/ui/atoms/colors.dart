import 'package:flutter/material.dart';
import 'package:psito_games_ui/psito_games_ui.dart';

abstract final class PsitoColors {
  static const felt = Color(0xFF6B3A48);
  static const feltGlow = Color(0xFF7E4A58);
  static const feltDark = Color(0xFF52293A);
  static const feltLight = Color(0xFFB88A98);
  static const cream = Color(0xFFF6EED6);
  static const black = Color(0xFF3B3842);
  static const edge = Color(0xFFAE9A74);
  static const accent = Color(0xFFFFC107);
  static const onFelt = Color(0xFFF3EFE0);
  static const onFeltMuted = Color(0xFFD6B6C0);
  static const barTop = Color(0xFF4E2A38);
  static const barBottom = Color(0xFF41222F);
}

/// The wine felt of the table, for the shared widgets.
const spiderPalette = GamePalette(
  felt: PsitoColors.felt,
  feltGlow: PsitoColors.feltGlow,
  feltDark: PsitoColors.feltDark,
  feltLight: PsitoColors.feltLight,
  barTop: PsitoColors.barTop,
  barBottom: PsitoColors.barBottom,
  onFelt: PsitoColors.onFelt,
  onFeltMuted: PsitoColors.onFeltMuted,
  cream: PsitoColors.cream,
  ink: PsitoColors.black,
);
