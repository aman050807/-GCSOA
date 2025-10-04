import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/glass_card.dart';
import '../../widgets/adaptive_progress_bar.dart';
import '../../state/app_state.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return ListView(
      children: [
        const SizedBox(height: 8),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overall Completion', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              AdaptiveProgressBar(value: appState.completionPercent),
              const SizedBox(height: 8),
              Text('${(appState.completionPercent * 100).round()}% complete'),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Subject Strengths', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final subjects = appState.subjects;
                            final index = value.toInt();
                            if (index >= 0 && index < subjects.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(subjects[index].name.substring(0, 1)),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(appState.subjects.length, (i) {
                      final s = appState.subjects[i];
                      final conf = appState.confidenceBySubject[s.id] ?? 0.5;
                      final score = (appState.lastQuizBySubject[s.id]?.scorePercent ?? 0.5);
                      final strength = (conf * 0.5 + score * 0.5);
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(toY: strength * 100, color: s.color, width: 14, borderRadius: BorderRadius.circular(6)),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adaptive Feedback', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              ...appState.latestSuggestions.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_fix_high_rounded, color: Colors.indigo),
                        const SizedBox(width: 10),
                        Expanded(child: Text(s)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
