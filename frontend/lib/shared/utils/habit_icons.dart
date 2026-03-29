import 'package:flutter/material.dart';

/// Maps icon name strings (stored in the backend) to Material [IconData].
const Map<String, IconData> habitIconMap = {
  'fitness': Icons.fitness_center,
  'book': Icons.menu_book,
  'water': Icons.water_drop,
  'meditation': Icons.self_improvement,
  'sleep': Icons.bedtime,
  'run': Icons.directions_run,
  'code': Icons.code,
  'music': Icons.music_note,
  'food': Icons.restaurant,
  'walk': Icons.directions_walk,
  'study': Icons.school,
  'clean': Icons.cleaning_services,
  'money': Icons.savings,
  'health': Icons.favorite,
  'default': Icons.check_circle_outline,
};

/// Resolves an icon name to [IconData], falling back to a default icon.
IconData resolveHabitIcon(String iconName) {
  if (iconName.isEmpty) return habitIconMap['default']!;
  return habitIconMap[iconName] ?? habitIconMap['default']!;
}

/// Predefined color palette for habit color pickers.
const List<HabitColorOption> habitColorOptions = [
  HabitColorOption(name: 'Red', hex: '#F44336', color: Color(0xFFF44336)),
  HabitColorOption(name: 'Orange', hex: '#FF9800', color: Color(0xFFFF9800)),
  HabitColorOption(name: 'Green', hex: '#4CAF50', color: Color(0xFF4CAF50)),
  HabitColorOption(name: 'Blue', hex: '#2196F3', color: Color(0xFF2196F3)),
  HabitColorOption(name: 'Purple', hex: '#9C27B0', color: Color(0xFF9C27B0)),
  HabitColorOption(name: 'Teal', hex: '#009688', color: Color(0xFF009688)),
  HabitColorOption(name: 'Pink', hex: '#E91E63', color: Color(0xFFE91E63)),
  HabitColorOption(name: 'Amber', hex: '#FFC107', color: Color(0xFFFFC107)),
];

class HabitColorOption {
  final String name;
  final String hex;
  final Color color;

  const HabitColorOption({
    required this.name,
    required this.hex,
    required this.color,
  });
}

/// Parses a hex color string (e.g. "#FF9800") into a [Color].
/// Returns [fallback] if parsing fails.
Color parseHabitColor(String? hex, Color fallback) {
  if (hex == null || hex.isEmpty) return fallback;
  try {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    if (clean.length == 8) {
      return Color(int.parse(clean, radix: 16));
    }
  } catch (_) {}
  return fallback;
}
