import 'package:flutter/material.dart';

enum StyleCategory { hair, beard }

class TryOnStyle {
  final String id;
  final String name;
  final StyleCategory category;
  final String assetPath;
  final double verticalOffset; // Relative Y anchor adjustment
  final double scaleFactor;    // Relative scale multiplier
  final Color primaryColor;    // Fallback color for vector/preview rendering

  const TryOnStyle({
    required this.id,
    required this.name,
    required this.category,
    required this.assetPath,
    this.verticalOffset = 0.0,
    this.scaleFactor = 1.0,
    required this.primaryColor,
  });

  static const List<TryOnStyle> hairstyles = [
    TryOnStyle(
      id: 'h_crew_cut',
      name: 'Crew Cut',
      category: StyleCategory.hair,
      assetPath: 'assets/styles/hair_crew_cut.png',
      verticalOffset: -0.42,
      scaleFactor: 1.15,
      primaryColor: Color(0xFF2C1B18),
    ),
    TryOnStyle(
      id: 'h_buzz_cut',
      name: 'Buzz Cut',
      category: StyleCategory.hair,
      assetPath: 'assets/styles/hair_buzz_cut.png',
      verticalOffset: -0.40,
      scaleFactor: 1.10,
      primaryColor: Color(0xFF1E1412),
    ),
    TryOnStyle(
      id: 'h_fade',
      name: 'Classic Fade',
      category: StyleCategory.hair,
      assetPath: 'assets/styles/hair_fade.png',
      verticalOffset: -0.43,
      scaleFactor: 1.20,
      primaryColor: Color(0xFF3A2420),
    ),
    TryOnStyle(
      id: 'h_low_fade',
      name: 'Low Fade',
      category: StyleCategory.hair,
      assetPath: 'assets/styles/hair_low_fade.png',
      verticalOffset: -0.43,
      scaleFactor: 1.18,
      primaryColor: Color(0xFF2B1D19),
    ),
    TryOnStyle(
      id: 'h_mid_fade',
      name: 'Mid Fade',
      category: StyleCategory.hair,
      assetPath: 'assets/styles/hair_mid_fade.png',
      verticalOffset: -0.44,
      scaleFactor: 1.20,
      primaryColor: Color(0xFF33201C),
    ),
    TryOnStyle(
      id: 'h_high_fade',
      name: 'High Fade',
      category: StyleCategory.hair,
      assetPath: 'assets/styles/hair_high_fade.png',
      verticalOffset: -0.45,
      scaleFactor: 1.22,
      primaryColor: Color(0xFF211513),
    ),
    TryOnStyle(
      id: 'h_pompadour',
      name: 'Pompadour',
      category: StyleCategory.hair,
      assetPath: 'assets/styles/hair_pompadour.png',
      verticalOffset: -0.52,
      scaleFactor: 1.30,
      primaryColor: Color(0xFF1A1210),
    ),
    TryOnStyle(
      id: 'h_quiff',
      name: 'Quiff',
      category: StyleCategory.hair,
      assetPath: 'assets/styles/hair_quiff.png',
      verticalOffset: -0.48,
      scaleFactor: 1.25,
      primaryColor: Color(0xFF2E1C18),
    ),
    TryOnStyle(
      id: 'h_side_part',
      name: 'Side Part',
      category: StyleCategory.hair,
      assetPath: 'assets/styles/hair_side_part.png',
      verticalOffset: -0.44,
      scaleFactor: 1.18,
      primaryColor: Color(0xFF241815),
    ),
    TryOnStyle(
      id: 'h_curly_hair',
      name: 'Curly Hair',
      category: StyleCategory.hair,
      assetPath: 'assets/styles/hair_curly.png',
      verticalOffset: -0.46,
      scaleFactor: 1.28,
      primaryColor: Color(0xFF1B110E),
    ),
    TryOnStyle(
      id: 'h_medium_hair',
      name: 'Medium Hair',
      category: StyleCategory.hair,
      assetPath: 'assets/styles/hair_medium.png',
      verticalOffset: -0.45,
      scaleFactor: 1.25,
      primaryColor: Color(0xFF3D2721),
    ),
    TryOnStyle(
      id: 'h_long_hair',
      name: 'Long Hair',
      category: StyleCategory.hair,
      assetPath: 'assets/styles/hair_long.png',
      verticalOffset: -0.46,
      scaleFactor: 1.35,
      primaryColor: Color(0xFF261714),
    ),
  ];

  static const List<TryOnStyle> beardStyles = [
    TryOnStyle(
      id: 'b_clean_shave',
      name: 'Clean Shave',
      category: StyleCategory.beard,
      assetPath: 'assets/styles/beard_clean_shave.png',
      verticalOffset: 0.25,
      scaleFactor: 1.0,
      primaryColor: Colors.transparent,
    ),
    TryOnStyle(
      id: 'b_light_stubble',
      name: 'Light Stubble',
      category: StyleCategory.beard,
      assetPath: 'assets/styles/beard_light_stubble.png',
      verticalOffset: 0.22,
      scaleFactor: 1.05,
      primaryColor: Color(0x772B1D19),
    ),
    TryOnStyle(
      id: 'b_heavy_stubble',
      name: 'Heavy Stubble',
      category: StyleCategory.beard,
      assetPath: 'assets/styles/beard_heavy_stubble.png',
      verticalOffset: 0.22,
      scaleFactor: 1.08,
      primaryColor: Color(0xAA211513),
    ),
    TryOnStyle(
      id: 'b_short_beard',
      name: 'Short Beard',
      category: StyleCategory.beard,
      assetPath: 'assets/styles/beard_short.png',
      verticalOffset: 0.24,
      scaleFactor: 1.12,
      primaryColor: Color(0xFF2B1D19),
    ),
    TryOnStyle(
      id: 'b_full_beard',
      name: 'Full Beard',
      category: StyleCategory.beard,
      assetPath: 'assets/styles/beard_full.png',
      verticalOffset: 0.26,
      scaleFactor: 1.25,
      primaryColor: Color(0xFF1E1412),
    ),
    TryOnStyle(
      id: 'b_goatee',
      name: 'Goatee',
      category: StyleCategory.beard,
      assetPath: 'assets/styles/beard_goatee.png',
      verticalOffset: 0.26,
      scaleFactor: 0.95,
      primaryColor: Color(0xFF241815),
    ),
    TryOnStyle(
      id: 'b_van_dyke',
      name: 'Van Dyke',
      category: StyleCategory.beard,
      assetPath: 'assets/styles/beard_van_dyke.png',
      verticalOffset: 0.26,
      scaleFactor: 0.95,
      primaryColor: Color(0xFF2E1C18),
    ),
    TryOnStyle(
      id: 'b_moustache',
      name: 'Moustache',
      category: StyleCategory.beard,
      assetPath: 'assets/styles/beard_moustache.png',
      verticalOffset: 0.18,
      scaleFactor: 0.90,
      primaryColor: Color(0xFF1A1210),
    ),
  ];
}
