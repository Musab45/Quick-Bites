import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/widgets/primary_button.dart';
import 'package:mobile/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.fromPath});

  final String? fromPath;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await ref
        .read(authNotifierProvider.notifier)
        .login(
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
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 17),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        color: colorScheme.surfaceContainerLowest,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.onSurface.withValues(alpha: 0.06),
                                blurRadius: 40,
                                offset: Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(
                                  Icons.restaurant,
                                  size: 44,
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: const Icon(
                                    Icons.bolt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'QuickBite',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    Text(
                      'Welcome Back',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login to continue your food journey',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _fieldDecoration(
                        colorScheme: colorScheme,
                        hint: 'Email address',
                        icon: Icons.mail_outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _fieldDecoration(
                        colorScheme: colorScheme,
                        hint: 'Password',
                        icon: Icons.lock_outline,
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
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Forgot password is coming soon.'),
                            ),
                          );
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    if (auth.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: colorScheme.error,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.error!,
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    PrimaryButton(
                      label: auth.isLoading ? 'Logging in...' : 'Log In',
                      onPressed: auth.isLoading ? () {} : _submit,
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR LOGIN WITH',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.outline,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialCircle(
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuD7EXbtnHXj2jVvyXxx4IXE6EyHs641HT9-PHCdWET7gDPeXgnchA71AxADeqw_uk0bvZkOLoSuIvL1D9C0CiEz5spcI-rWvn7WIKkZfs-nJ7DivQwLhb1FtR2anZtihAbhk58Uu4gtuRbA7ncVkB5DxDO95QNJbHjnGvqsxKN1iqDwIUTrzTQs13V-XBsBrU7yC18n_9e0osWxjy_P1LjxMFTyd50JnuaYehqVbaVCaD0lIStdfAZNxObbtoWql3QYNkAB6WeWtA',
                            width: 24,
                            height: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        _socialCircle(
                          child: const Icon(
                            Icons.facebook_rounded,
                            size: 30,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 14),
                        _socialCircle(
                          child: const Icon(Icons.apple, size: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    TextButton(
                      onPressed: () {
                        final from = widget.fromPath;
                        if (from == null || from.isEmpty) {
                          context.push('/register');
                          return;
                        }
                        context.push('/register?from=${Uri.encodeComponent(from)}');
                      },
                      child: const Text("Don't have an account? Sign Up"),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialCircle({required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
