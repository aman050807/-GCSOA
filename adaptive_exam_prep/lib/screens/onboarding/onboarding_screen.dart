import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../theme/app_theme.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../state/app_state.dart';
import 'package:provider/provider.dart';
import '../input/input_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text('Adaptive Exam Prep', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text('Personalized schedules. Smart quizzes. Faster progress.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: 16),
          Expanded(
            child: PageView(
              controller: _controller,
              children: const [
                _OnbCard(title: 'Learn what matters', subtitle: 'We focus your study on the topics you\'re weakest at.'),
                _OnbCard(title: 'Adaptive quizzes', subtitle: 'Instant feedback with smarter follow-ups to solidify knowledge.'),
                _OnbCard(title: 'See your progress', subtitle: 'Beautiful dashboards and insights that guide your next step.'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: const ExpandingDotsEffect(activeDotColor: Colors.white, dotColor: Colors.white54, dotHeight: 8, dotWidth: 8),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () {
                context.read<AppState>().completeOnboarding();
                Navigator.of(context).pushReplacementNamed(InputScreen.route);
              },
              child: const Text('Get Started'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OnbCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _OnbCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 450),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.indigo.shade600, size: 56),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
