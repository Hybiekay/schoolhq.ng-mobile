import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/auth_provider.dart';
import 'package:schoolhq_ng/widget/responsive_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await ref
          .read(authProvider.notifier)
          .login(_email.text.trim(), _password.text.trim());

      // Use pushReplacement for better UX
      if (context.mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _LoginMobileContent(
        formKey: _formKey,
        email: _email,
        password: _password,
        obscure: _obscure,
        loading: _loading,
        onToggleObscure: () => setState(() => _obscure = !_obscure),
        onLogin: _login,
        onForgotPassword: () => context.push('/forgot-password'),
      ),
      tablet: _LoginTabletContent(
        formKey: _formKey,
        email: _email,
        password: _password,
        obscure: _obscure,
        loading: _loading,
        onToggleObscure: () => setState(() => _obscure = !_obscure),
        onLogin: _login,
        onForgotPassword: () => context.push('/forgot-password'),
      ),
      desktop: _LoginDesktopContent(
        formKey: _formKey,
        email: _email,
        password: _password,
        obscure: _obscure,
        loading: _loading,
        onToggleObscure: () => setState(() => _obscure = !_obscure),
        onLogin: _login,
        onForgotPassword: () => context.push('/forgot-password'),
      ),
    );
  }
}

// Reusable Widgets

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  const _LoginForm({
    required this.formKey,
    required this.email,
    required this.password,
    required this.obscure,
    required this.loading,
    required this.onToggleObscure,
    required this.onLogin,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.isMobile(context) ? 20 : 32,
        vertical: ResponsiveLayout.isMobile(context) ? 24 : 32,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!ResponsiveLayout.isMobile(context)) ...[
              Text('Welcome Back', style: AppTextStyles.headingLarge),
              const SizedBox(height: 8),
              Text(
                'Enter your credentials to continue',
                style: AppTextStyles.subtitle.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
            ],
            _EmailField(controller: email),
            const SizedBox(height: 20),
            _PasswordField(
              controller: password,
              obscure: obscure,
              onToggleObscure: onToggleObscure,
            ),
            const SizedBox(height: 16),
            _ForgotPasswordButton(onPressed: onForgotPassword),
            const SizedBox(height: 24),
            _LoginButton(loading: loading, onPressed: onLogin),
            if (ResponsiveLayout.isMobile(context)) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _SignUpPrompt(),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;

  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: 'Email Address',
        prefixIcon: const Icon(Icons.email_outlined, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
          ),
          onPressed: onToggleObscure,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ForgotPasswordButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Forgot Password?',
          style: AppTextStyles.body.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _LoginButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: loading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue', style: AppTextStyles.button),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTextStyles.body.copyWith(color: Colors.grey.shade600),
        ),
        TextButton(
          onPressed: () => context.push('/register'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign up',
            style: AppTextStyles.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// Responsive Layout Variations

class _LoginMobileContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  const _LoginMobileContent({
    required this.formKey,
    required this.email,
    required this.password,
    required this.obscure,
    required this.loading,
    required this.onToggleObscure,
    required this.onLogin,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset(AppImages.logo, height: 60, width: 60),
              const SizedBox(height: 24),
              Text('Welcome Back', style: AppTextStyles.headingLarge),
              const SizedBox(height: 8),
              Text(
                'Login to continue to your school dashboard',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _LoginForm(
                formKey: formKey,
                email: email,
                password: password,
                obscure: obscure,
                loading: loading,
                onToggleObscure: onToggleObscure,
                onLogin: onLogin,
                onForgotPassword: onForgotPassword,
              ),
              const SizedBox(height: 40),
              Text(
                'By continuing, you agree to our Terms and Privacy Policy',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginTabletContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  const _LoginTabletContent({
    required this.formKey,
    required this.email,
    required this.password,
    required this.obscure,
    required this.loading,
    required this.onToggleObscure,
    required this.onLogin,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppImages.logo, height: 80, width: 80),
                const SizedBox(height: 32),
                Text('Welcome Back', style: AppTextStyles.headingLarge),
                const SizedBox(height: 8),
                Text(
                  'Login to continue to your school dashboard',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 40),
                _LoginForm(
                  formKey: formKey,
                  email: email,
                  password: password,
                  obscure: obscure,
                  loading: loading,
                  onToggleObscure: onToggleObscure,
                  onLogin: onLogin,
                  onForgotPassword: onForgotPassword,
                ),
                const SizedBox(height: 40),
                _SignUpPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginDesktopContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  const _LoginDesktopContent({
    required this.formKey,
    required this.email,
    required this.password,
    required this.obscure,
    required this.loading,
    required this.onToggleObscure,
    required this.onLogin,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Left side - Brand/Info Section
          Expanded(
            flex: 5,
            child: Container(
              color: AppColors.primary.withOpacity(0.05),
              padding: const EdgeInsets.all(60),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(AppImages.logo, height: 48, width: 48),
                        const SizedBox(width: 12),
                        Text(
                          'SchoolHQ',
                          style: AppTextStyles.headingLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    Text(
                      'Transform Your\nSchool Experience',
                      style: AppTextStyles.headingLarge.copyWith(height: 1.2),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Access your personalized dashboard, track progress, and connect with your educational community.',
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _FeatureList(),
                  ],
                ),
              ),
            ),
          ),
          // Right side - Login Form
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login to Your Account',
                    style: AppTextStyles.headingLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your credentials to access your dashboard',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 40),
                  _LoginForm(
                    formKey: formKey,
                    email: email,
                    password: password,
                    obscure: obscure,
                    loading: loading,
                    onToggleObscure: onToggleObscure,
                    onLogin: onLogin,
                    onForgotPassword: onForgotPassword,
                  ),
                  const SizedBox(height: 40),
                  _SignUpPrompt(),
                  const SizedBox(height: 20),
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy.',
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      {'icon': Icons.school_outlined, 'text': 'Personalized Learning Paths'},
      {'icon': Icons.track_changes_outlined, 'text': 'Progress Tracking'},
      {'icon': Icons.group_outlined, 'text': 'Community Engagement'},
      {'icon': Icons.insights_outlined, 'text': 'Insightful Analytics'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    feature['text'] as String,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
