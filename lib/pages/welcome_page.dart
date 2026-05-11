import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../l10n/app_localizations.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authService.currentUser != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (!settingsService.onboardingDone) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: cs.primaryContainer,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(blurRadius: 14, color: Colors.black12, offset: Offset(0, 6)),
              ],
              border: Border.all(color: cs.outlineVariant, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(Icons.auto_stories_rounded, size: 72, color: cs.primary),
                    const Positioned(
                      top: 15,
                      right: 18,
                      child: Icon(Icons.favorite, color: Colors.pinkAccent, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Readify ✨',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.welcomeSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, height: 1.4, color: cs.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.welcomeTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: cs.primary),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(l10n.welcomeLogin, style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: cs.primary, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(l10n.welcomeRegister, style: TextStyle(fontSize: 16, color: cs.primary)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
