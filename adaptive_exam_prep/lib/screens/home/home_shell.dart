import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/adaptive_progress_bar.dart';
import '../../state/app_state.dart';
import '../schedule/schedule_screen.dart';
import '../quiz/quiz_screen.dart';
import '../progress/progress_screen.dart';

class HomeShell extends StatefulWidget {
  static const String route = '/home';
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void setIndex(int newIndex) {
    setState(() => _index = newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeDashboard(),
      const ScheduleScreen(),
      const QuizScreen(),
      const ProgressScreen(),
    ];

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text('Adaptive Exam Prep'),
        actions: [
          IconButton(
            onPressed: () => context.read<AppState>().reshuffleSchedule(reason: 'manual'),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reshuffle Schedule',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appGradient),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: pages[_index],
          ),
        ),
      ),
      bottomNavigationBar: _NavBar(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void didUpdateWidget(covariant HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

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
              Text('Today\'s Plan', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  key: ValueKey(appState.schedule.length.toString() + appState.latestSuggestions.length.toString()),
                  children: [
                    Row(
                      children: [
                        Expanded(child: AdaptiveProgressBar(value: appState.completionPercent)),
                        const SizedBox(width: 10),
                        Text('${(appState.completionPercent * 100).round()}%'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Last reshuffle: ${TimeOfDay.fromDateTime(appState.lastReshuffleAt).format(context)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: appState.todaysSessions.take(3).map((s) {
                        final subj = appState.subjects.firstWhere((e) => e.id == s.subjectId);
                        return Chip(
                          label: Text('${subj.name} · ${s.startTimeOfDay.format(context)}'),
                          avatar: Icon(subj.icon, color: subj.color, size: 18),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: subj.color.withOpacity(0.2)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adaptive Suggestions', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              ...appState.latestSuggestions.map((s) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_rounded, color: AppTheme.accentAmber),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s)),
                    ],
                  )),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quick Actions', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.findAncestorStateOfType<_HomeShellState>()?.setIndex(1),
                      icon: const Icon(Icons.schedule_rounded),
                      label: const Text('View Schedule'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.findAncestorStateOfType<_HomeShellState>()?.setIndex(2),
                      icon: const Icon(Icons.quiz_rounded),
                      label: const Text('Take Quiz'),
                    ),
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

class _NavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _NavBar({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: onChanged,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.schedule_rounded), label: 'Schedule'),
            NavigationDestination(icon: Icon(Icons.quiz_rounded), label: 'Quiz'),
            NavigationDestination(icon: Icon(Icons.insights_rounded), label: 'Progress'),
          ],
        ),
      ),
    );
  }
}
