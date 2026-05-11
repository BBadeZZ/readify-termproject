import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyError(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String error) {
    final l10n = AppLocalizations.of(context)!;
    if (error.contains('email-already-in-use')) return l10n.registerErrEmailInUse;
    if (error.contains('invalid-email')) return l10n.registerErrEmailInvalid;
    if (error.contains('weak-password')) return l10n.registerErrWeakPassword;
    return l10n.registerErrGeneral;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: cs.primaryContainer,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(blurRadius: 14, color: Colors.black12, offset: Offset(0, 6)),
              ],
              border: Border.all(color: cs.outlineVariant, width: 2),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: cs.primaryContainer,
                    child: Icon(Icons.person_add_rounded, size: 44, color: cs.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.registerCreateAccount,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: cs.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.registerSubtitle,
                    style: TextStyle(fontSize: 15, color: cs.primary),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(l10n.registerFullName, Icons.person_outline),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return l10n.registerErrNameEmpty;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(l10n.registerEmail, Icons.email_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return l10n.registerErrEmailEmpty;
                      if (!v.contains('@')) return l10n.registerErrEmailInvalid;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(l10n.registerPassword, Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: cs.primary,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.registerErrPasswordEmpty;
                      if (v.length < 6) return l10n.registerErrPasswordShort;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: _inputDecoration(l10n.registerConfirmPassword, Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                          color: cs.primary,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.registerErrConfirmEmpty;
                      if (v != _passwordController.text) return l10n.registerErrPasswordMismatch;
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(l10n.registerButton, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.registerHaveAccount, style: TextStyle(color: cs.primary)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: Text(
                          l10n.registerLoginLink,
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: cs.primary),
      prefixIcon: Icon(icon, color: cs.primary),
      filled: true,
      fillColor: cs.primaryContainer.withValues(alpha: 0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
    );
  }
}
