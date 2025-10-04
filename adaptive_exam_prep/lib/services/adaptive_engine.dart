import 'dart:math';

import '../models/quiz.dart';
import '../models/study_session.dart';
import '../models/subject.dart';

/// Heuristic adaptive engine for demo purposes.
/// Weights subjects by confidence and latest quiz score, then produces a schedule and suggestions.
class AdaptiveEngine {
  static List<StudySession> generateSchedule({
    required List<Subject> subjects,
    required Map<String, double> confidenceBySubject, // 0..1 higher => more confident
    required Map<String, QuizResult?> lastQuizBySubject,
    int sessionCount = 6,
    Duration sessionDuration = const Duration(minutes: 40),
    DateTime? baseTime,
  }) {
    final now = baseTime ?? DateTime.now();
    // Create weighting per subject: lower confidence and lower score => higher weight
    final Map<String, double> weights = {};
    for (final subject in subjects) {
      final confidence = (confidenceBySubject[subject.id] ?? 0.5).clamp(0.0, 1.0);
      final quiz = lastQuizBySubject[subject.id];
      final lastScore = quiz?.scorePercent ?? 0.5; // neutral if no data
      final difficultySignal = (1.0 - confidence);
      final performanceSignal = (1.0 - lastScore);
      final w = 0.6 * difficultySignal + 0.4 * performanceSignal; // tuneable
      weights[subject.id] = max(0.05, w); // avoid zeros
    }

    // Normalize weights
    final sum = weights.values.fold<double>(0, (a, b) => a + b);
    final normalized = weights.map((k, v) => MapEntry(k, v / (sum == 0 ? 1 : sum)));

    // Allocate sessions proportionally across the day
    final List<StudySession> sessions = [];
    final dayStart = DateTime(now.year, now.month, now.day, 9, 0);
    final List<DateTime> slots = List.generate(sessionCount, (i) => dayStart.add(Duration(hours: i * 2)));

    // Create a pool of subject IDs proportional to weight
    final List<String> pool = [];
    normalized.forEach((subjectId, w) {
      final count = max(1, (w * sessionCount).round());
      pool.addAll(List.filled(count, subjectId));
    });

    final rng = Random(now.millisecondsSinceEpoch);
    for (int i = 0; i < sessionCount; i++) {
      final subjectId = pool[rng.nextInt(pool.length)];
      sessions.add(
        StudySession(
          id: 'sess_${now.millisecondsSinceEpoch}_$i',
          subjectId: subjectId,
          start: slots[min(i, slots.length - 1)],
          duration: sessionDuration,
          updated: true,
          updatedAt: DateTime.now(),
        ),
      );
    }
    return sessions;
  }

  static List<String> generateSuggestions({
    required List<Subject> subjects,
    required Map<String, double> confidenceBySubject, // 0..1
    required Map<String, QuizResult?> lastQuizBySubject,
  }) {
    final List<String> suggestions = [];
    for (final subject in subjects) {
      final conf = (confidenceBySubject[subject.id] ?? 0.5).clamp(0.0, 1.0);
      final score = (lastQuizBySubject[subject.id]?.scorePercent ?? 0.5).clamp(0.0, 1.0);
      if (conf >= 0.7 && score < 0.6) {
        suggestions.add('You rated yourself strong in ${subject.name}, but your quiz score was low — plan a focused ${subject.name} review tomorrow.');
      } else if (conf < 0.4 && score >= 0.7) {
        suggestions.add('Confidence is low for ${subject.name}, but performance is solid — schedule a light recap to build confidence.');
      } else if (conf < 0.4 && score < 0.6) {
        suggestions.add('${subject.name} needs attention — let\'s prioritize two short sessions and a quick quiz.');
      }
    }

    if (suggestions.isEmpty) {
      suggestions.add('Nice balance across subjects. Keep a steady cadence and adjust after next quiz.');
    }
    return suggestions;
  }
}
