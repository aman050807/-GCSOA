/// Quiz models for multiple choice flow.
class QuizOption {
  final String id;
  final String text;
  final bool isCorrect;

  const QuizOption({required this.id, required this.text, required this.isCorrect});
}

class QuizQuestion {
  final String id;
  final String subjectId;
  final String prompt;
  final List<QuizOption> options;

  const QuizQuestion({
    required this.id,
    required this.subjectId,
    required this.prompt,
    required this.options,
  });
}

class QuizResult {
  final String subjectId;
  final int correct;
  final int total;
  final double scorePercent; // 0..1
  final DateTime takenAt;

  const QuizResult({
    required this.subjectId,
    required this.correct,
    required this.total,
    required this.scorePercent,
    required this.takenAt,
  });
}
