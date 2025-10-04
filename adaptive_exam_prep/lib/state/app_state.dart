import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../models/study_session.dart';
import '../models/quiz.dart';
import '../services/adaptive_engine.dart';

/// Top-level application state with simple Provider-based management.
class AppState extends ChangeNotifier {
  bool hasCompletedOnboarding = false;
  bool hasProvidedConfidence = false;

  // Subjects and confidence map 0..1
  final List<Subject> subjects = List.of(Subject.defaults);
  final Map<String, double> confidenceBySubject = {};

  // Scheduling and progress
  List<StudySession> schedule = [];
  final Map<String, QuizResult> lastQuizBySubject = {};
  final Set<String> completedSessionIds = {};
  List<String> latestSuggestions = [];
  DateTime lastReshuffleAt = DateTime.now();

  void initializeDefaults() {
    for (final s in subjects) {
      confidenceBySubject[s.id] = 0.5; // neutral default
    }
    // Build an initial schedule
    schedule = AdaptiveEngine.generateSchedule(
      subjects: subjects,
      confidenceBySubject: confidenceBySubject,
      lastQuizBySubject: lastQuizBySubject,
    );
    latestSuggestions = AdaptiveEngine.generateSuggestions(
      subjects: subjects,
      confidenceBySubject: confidenceBySubject,
      lastQuizBySubject: lastQuizBySubject,
    );
    lastReshuffleAt = DateTime.now();
    notifyListeners();
  }

  void completeOnboarding() {
    hasCompletedOnboarding = true;
    notifyListeners();
  }

  void saveConfidence(Map<String, double> newConfidenceBySubject) {
    newConfidenceBySubject.forEach((key, value) {
      confidenceBySubject[key] = value.clamp(0.0, 1.0);
    });
    hasProvidedConfidence = true;
    reshuffleSchedule(reason: 'confidence_update');
  }

  void reshuffleSchedule({String? reason}) {
    final newSchedule = AdaptiveEngine.generateSchedule(
      subjects: subjects,
      confidenceBySubject: confidenceBySubject,
      lastQuizBySubject: lastQuizBySubject,
    );

    // Mark entries as updated; keep completion mapping when possible by subject/time proximity
    schedule = newSchedule.map((s) {
      final wasCompleted = completedSessionIds.contains(s.id);
      return s.copyWith(completed: wasCompleted, updated: true, updatedAt: DateTime.now());
    }).toList();

    latestSuggestions = AdaptiveEngine.generateSuggestions(
      subjects: subjects,
      confidenceBySubject: confidenceBySubject,
      lastQuizBySubject: lastQuizBySubject,
    );
    lastReshuffleAt = DateTime.now();
    notifyListeners();
  }

  void markSessionCompleted(String sessionId, bool completed) {
    if (completed) {
      completedSessionIds.add(sessionId);
    } else {
      completedSessionIds.remove(sessionId);
    }
    schedule = schedule.map((s) => s.id == sessionId ? s.copyWith(completed: completed) : s).toList();
    notifyListeners();
  }

  void submitQuizResult(QuizResult result) {
    lastQuizBySubject[result.subjectId] = result;
    // Trigger re-evaluation of schedule and suggestions
    reshuffleSchedule(reason: 'quiz_result');
  }

  double get completionPercent {
    if (schedule.isEmpty) return 0;
    final done = schedule.where((s) => s.completed).length;
    return done / schedule.length;
  }

  List<StudySession> get todaysSessions {
    final now = DateTime.now();
    return schedule.where((s) => s.start.year == now.year && s.start.month == now.month && s.start.day == now.day).toList();
  }
}
