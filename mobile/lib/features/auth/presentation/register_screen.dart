import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/widgets/app_bar_system.dart';
import 'package:mobile/core/widgets/primary_button.dart';
import 'package:mobile/providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.fromPath});

  final String? fromPath;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept terms and conditions.')),
      );
      return;
    }

    final ok = await ref
        .read(authNotifierProvider.notifier)
        .register(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) {
      return;
    }
    if (ok) {
      context.go(widget.fromPath ?? '/home');
    }
  }

  InputDecoration _fieldDecoration({
    required ColorScheme colorScheme,
    required String label,
    required String hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      alignLabelWithHint: true,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent, width: 0),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent, width: 0),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: QuickBiteAppBars.title(
        title: 'QuickBite',
        onBack: () => context.pop(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.18),
              colorScheme.surface,
            ],
            stops: [0, 0.55, 1],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.sm),
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Create Account',
              textAlign: TextAlign.center,
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Join the QuickBite community today',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withValues(alpha: 0.06),
                    blurRadius: 40,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: _fieldDecoration(
                      colorScheme: colorScheme,
                      label: 'FULL NAME',
                      hint: 'Enter your name',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _fieldDecoration(
                      colorScheme: colorScheme,
                      label: 'EMAIL ADDRESS',
                      hint: 'name@example.com',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _fieldDecoration(
                      colorScheme: colorScheme,
                      label: 'PHONE NUMBER',
                      hint: '+1 (555) 000-0000',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _fieldDecoration(
                      colorScheme: colorScheme,
                      label: 'PASSWORD',
                      hint: 'Min. 8 characters',
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'By signing up, you agree to our Terms and Conditions',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (auth.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        auth.error!,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  PrimaryButton(
                    label: auth.isLoading ? 'Creating account...' : 'Sign Up',
                    onPressed: auth.isLoading ? () {} : _submit,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR SIGN UP WITH',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _SocialCircle(icon: Icons.g_mobiledata_rounded),
                      _SocialCircle(icon: Icons.facebook_rounded),
                      _SocialCircle(icon: Icons.apple_rounded),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: () {
                  final from = widget.fromPath;
                  if (from == null || from.isEmpty) {
                    context.go('/login');
                    return;
                  }
                  context.go('/login?from=${Uri.encodeComponent(from)}');
                },
                child: const Text('Already have an account? Log In'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _SocialCircle extends StatelessWidget {
  const _SocialCircle({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 26, color: colorScheme.onSurface),
    );
  }
}
