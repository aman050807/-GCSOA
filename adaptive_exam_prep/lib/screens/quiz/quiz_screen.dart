import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/glass_card.dart';
import '../../state/app_state.dart';
import '../../models/quiz.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _questionIndex = 0;
  final Map<int, String> _selectedOptionIdByIndex = {};
  final Map<String, int> _correctBySubject = {}; // subjectId -> correct count
  final Map<String, int> _totalBySubject = {}; // subjectId -> total count

  List<QuizQuestion> get _demoQuestions => [
        QuizQuestion(
          id: 'q1',
          subjectId: 'math',
          prompt: 'What is the derivative of x^2?',
          options: const [
            QuizOption(id: 'a', text: '2x', isCorrect: true),
            QuizOption(id: 'b', text: 'x', isCorrect: false),
            QuizOption(id: 'c', text: 'x^2', isCorrect: false),
          ],
        ),
        QuizQuestion(
          id: 'q2',
          subjectId: 'science',
          prompt: 'What is H2O commonly known as?',
          options: const [
            QuizOption(id: 'a', text: 'Hydrogen Peroxide', isCorrect: false),
            QuizOption(id: 'b', text: 'Water', isCorrect: true),
            QuizOption(id: 'c', text: 'Oxygen', isCorrect: false),
          ],
        ),
        QuizQuestion(
          id: 'q3',
          subjectId: 'history',
          prompt: 'The Renaissance began in which country?',
          options: const [
            QuizOption(id: 'a', text: 'France', isCorrect: false),
            QuizOption(id: 'b', text: 'Italy', isCorrect: true),
            QuizOption(id: 'c', text: 'Germany', isCorrect: false),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final question = _demoQuestions[_questionIndex];

    return ListView(
      children: [
        const SizedBox(height: 8),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Question ${_questionIndex + 1} of ${_demoQuestions.length}', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(question.prompt, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              ...question.options.map((o) {
                final isSelected = _selectedOptionIdByIndex[_questionIndex] == o.id;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.indigo.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? Colors.indigo : Colors.black12),
                  ),
                  child: ListTile(
                    title: Text(o.text),
                    trailing: isSelected
                        ? Icon(o.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: o.isCorrect ? Colors.green : Colors.red)
                        : null,
                    onTap: () {
                      setState(() {
                        final previous = _selectedOptionIdByIndex[_questionIndex];
                        _selectedOptionIdByIndex[_questionIndex] = o.id;
                        // Update per-subject tallies without double counting
                        final subjectId = question.subjectId;
                        _totalBySubject[subjectId] = (_totalBySubject[subjectId] ?? 0) == 0
                            ? _demoQuestions.where((q) => q.subjectId == subjectId).length
                            : _totalBySubject[subjectId]!;
                        // Recompute correct count for this subject from selected answers so far
                        final correctNow = _demoQuestions
                            .asMap()
                            .entries
                            .where((e) => e.value.subjectId == subjectId)
                            .where((e) => _selectedOptionIdByIndex.containsKey(e.key))
                            .where((e) {
                          final chosenId = _selectedOptionIdByIndex[e.key];
                          return e.value.options.firstWhere((opt) => opt.id == chosenId).isCorrect;
                        }).length;
                        _correctBySubject[subjectId] = correctNow;
                      });
                    },
                  ),
                );
              }),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_questionIndex > 0)
                    TextButton(
                      onPressed: () {
                        setState(() => _questionIndex -= 1);
                      },
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_questionIndex < _demoQuestions.length - 1) {
                        setState(() => _questionIndex += 1);
                      } else {
                        // Submit per-subject results
                        final appState = context.read<AppState>();
                        final subjects = _demoQuestions.map((q) => q.subjectId).toSet();
                        for (final subjectId in subjects) {
                          final total = _demoQuestions.where((q) => q.subjectId == subjectId).length;
                          final correct = _correctBySubject[subjectId] ?? 0;
                          final score = total == 0 ? 0.0 : correct / total;
                          appState.submitQuizResult(
                            QuizResult(
                              subjectId: subjectId,
                              correct: correct,
                              total: total,
                              scorePercent: score,
                              takenAt: DateTime.now(),
                            ),
                          );
                        }
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Quiz Complete'),
                              content: const Text('Results applied per subject. Schedule reshuffled based on your performance.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Text(_questionIndex < _demoQuestions.length - 1 ? 'Next' : 'Finish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
