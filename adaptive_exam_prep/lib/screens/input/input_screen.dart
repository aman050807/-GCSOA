import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/gradient_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../state/app_state.dart';
import '../../models/subject.dart';
import '../home/home_shell.dart';

class InputScreen extends StatefulWidget {
  static const String route = '/input';
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final Map<String, double> _confidenceDraft = {};

  @override
  void initState() {
    super.initState();
    final subjects = context.read<AppState>().subjects;
    for (final s in subjects) {
      _confidenceDraft[s.id] = context.read<AppState>().confidenceBySubject[s.id] ?? 0.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<AppState>().subjects;

    return GradientScaffold(
      appBar: AppBar(title: const Text('Your Confidence Levels')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ...subjects.map((s) => GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(s.icon, color: s.color),
                        const SizedBox(width: 10),
                        Text(s.name, style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: _confidenceDraft[s.id] ?? 0.5,
                      onChanged: (v) => setState(() => _confidenceDraft[s.id] = v),
                      min: 0,
                      max: 1,
                      divisions: 10,
                      label: ((_confidenceDraft[s.id] ?? 0.5) * 100).round().toString(),
                    ),
                    Text('0 = Low confidence, 100 = High confidence', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<AppState>().saveConfidence(_confidenceDraft);
                Navigator.of(context).pushReplacementNamed(HomeShell.route);
              },
              icon: const Icon(Icons.auto_fix_high_rounded),
              label: const Text('Generate My Adaptive Plan'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
