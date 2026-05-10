import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6D8),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF4),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                blurRadius: 14,
                color: Colors.black12,
                offset: Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: Color(0xFFF7D774),
              width: 2,
            ),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE8A3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(
                    Icons.auto_stories_rounded,
                    size: 72,
                    color: Colors.brown,
                  ),
                  const Positioned(
                    top: 15,
                    right: 18,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.pinkAccent,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Readify ✨',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Smart Book Tracking\nand Reading Analytics App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  height: 1.4,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Cute, cozy and smart reading journal for book lovers 💛',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.brown, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 16, color: Colors.brown),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}