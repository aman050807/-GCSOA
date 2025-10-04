import 'package:flutter/material.dart';

/// Represents a scheduled study block for a specific subject.
class StudySession {
  final String id;
  final String subjectId;
  final DateTime start;
  final Duration duration;
  final bool updated;
  final DateTime updatedAt;
  final bool completed;

  const StudySession({
    required this.id,
    required this.subjectId,
    required this.start,
    required this.duration,
    this.updated = false,
    required this.updatedAt,
    this.completed = false,
  });

  TimeOfDay get startTimeOfDay => TimeOfDay(hour: start.hour, minute: start.minute);

  StudySession copyWith({
    String? id,
    String? subjectId,
    DateTime? start,
    Duration? duration,
    bool? updated,
    DateTime? updatedAt,
    bool? completed,
  }) {
    return StudySession(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      updated: updated ?? this.updated,
      updatedAt: updatedAt ?? this.updatedAt,
      completed: completed ?? this.completed,
    );
  }
}
