import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/gradient_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../state/app_state.dart';
import '../../models/study_session.dart';
import '../../models/subject.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final sessions = appState.schedule;

    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final s = sessions[index];
        final subj = appState.subjects.firstWhere((e) => e.id == s.subjectId);
        return _SessionCard(session: s, subject: subj);
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  final StudySession session;
  final Subject subject;
  const _SessionCard({required this.session, required this.subject});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(session.updated ? 0 : 0, session.updated ? 0 : 8, 0),
      child: GlassCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(backgroundColor: subject.color.withOpacity(0.15), child: Icon(subject.icon, color: subject.color)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(subject.name, style: Theme.of(context).textTheme.headlineSmall),
                      if (session.updated)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: subject.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: subject.color.withOpacity(0.3)),
                          ),
                          child: Text('Updated', style: TextStyle(color: subject.color, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Starts ${session.start.hour.toString().padLeft(2, '0')}:${session.start.minute.toString().padLeft(2, '0')} · ${session.duration.inMinutes} mins'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('Mark Done'),
                        selected: session.completed,
                        onSelected: (v) => context.read<AppState>().markSessionCompleted(session.id, v),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => context.read<AppState>().reshuffleSchedule(reason: 'slot_swap'),
                        icon: const Icon(Icons.swap_vert_rounded),
                        label: const Text('Reshuffle'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
