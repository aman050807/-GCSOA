import 'package:flutter/material.dart';

/// Domain model representing a study subject.
class Subject {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const Subject({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<Subject> defaults = [
    Subject(
      id: 'math',
      name: 'Math',
      icon: Icons.calculate_rounded,
      color: Color(0xFF4F46E5), // Indigo-600
    ),
    Subject(
      id: 'science',
      name: 'Science',
      icon: Icons.science_rounded,
      color: Color(0xFF10B981), // Emerald-500
    ),
    Subject(
      id: 'history',
      name: 'History',
      icon: Icons.menu_book_rounded,
      color: Color(0xFFF59E0B), // Amber-500
    ),
    Subject(
      id: 'language',
      name: 'Language',
      icon: Icons.language_rounded,
      color: Color(0xFF06B6D4), // Cyan-500
    ),
  ];
}
