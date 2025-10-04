import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/input/input_screen.dart';
import 'screens/home/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdaptiveExamPrepApp());
}

class AdaptiveExamPrepApp extends StatelessWidget {
  const AdaptiveExamPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..initializeDefaults(),
      child: MaterialApp(
        title: 'Adaptive Exam Prep',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const _LaunchGate(),
        routes: {
          InputScreen.route: (_) => const InputScreen(),
          HomeShell.route: (_) => const HomeShell(),
        },
      ),
    );
  }
}

/// LaunchGate decides the initial route based on onboarding completion.
class _LaunchGate extends StatelessWidget {
  const _LaunchGate();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.hasCompletedOnboarding) {
      return const OnboardingScreen();
    }
    if (!appState.hasProvidedConfidence) {
      return const InputScreen();
    }
    return const HomeShell();
  }
}
