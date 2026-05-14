import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  List<_Slide> _slides = [];

  List<_Slide> _buildSlides(ColorScheme cs, AppLocalizations l10n) => [
    _Slide(
      icon: Icons.auto_stories_rounded,
      title: l10n.onboarding1Title,
      description: l10n.onboarding1Desc,
      bgColor: cs.primaryContainer,
      circleColor: cs.primary.withValues(alpha: 0.2),
      iconColor: cs.primary,
    ),
    _Slide(
      icon: Icons.timer_rounded,
      title: l10n.onboarding2Title,
      description: l10n.onboarding2Desc,
      bgColor: cs.secondaryContainer,
      circleColor: cs.secondary.withValues(alpha: 0.2),
      iconColor: cs.secondary,
    ),
    _Slide(
      icon: Icons.search_rounded,
      title: l10n.onboarding3Title,
      description: l10n.onboarding3Desc,
      bgColor: cs.primaryContainer,
      circleColor: cs.primary.withValues(alpha: 0.2),
      iconColor: cs.primary,
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    await settingsService.completeOnboarding();
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    _slides = _buildSlides(cs, l10n);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(l10n.onboardingSkip, style: TextStyle(color: cs.primary, fontSize: 16)),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? cs.primary
                        : cs.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1 ? l10n.onboardingGetStarted : l10n.onboardingNext,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: slide.circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 72, color: slide.iconColor),
          ),
          const SizedBox(height: 28),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: slide.iconColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: slide.iconColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String description;
  final Color bgColor;
  final Color circleColor;
  final Color iconColor;

  const _Slide({
    required this.icon,
    required this.title,
    required this.description,
    required this.bgColor,
    required this.circleColor,
    required this.iconColor,
  });
}
