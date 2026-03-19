import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/feedback/app_snackbar.dart';
import 'package:schoolhq_ng/core/school/current_school.dart';
import 'package:schoolhq_ng/enum/user_role.dart';
import 'package:schoolhq_ng/providers/auth_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/utils/build_ext.dart';
import 'package:schoolhq_ng/views/auth/register/layout/desktop.dart';
import 'package:schoolhq_ng/views/auth/register/layout/mobile.dart';
import 'package:schoolhq_ng/views/auth/register/layout/tablet.dart';
import 'package:schoolhq_ng/views/auth/register/provider/registration_notifier.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final int step;
  const RegistrationScreen({super.key, required this.step});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _childNameController = TextEditingController();
  final _childGradeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;
  bool _termsAccepted = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || !_termsAccepted) {
      if (!_termsAccepted) {
        AppSnackBar.warning(context, 'Please accept the terms and conditions');
      }
      return;
    }

    setState(() => _loading = true);

    try {
      final selectedRole = ref.read(registrationProvider).role;
      if (selectedRole == null) {
        throw Exception('Please select a role');
      }

      await ref
          .read(authProvider.notifier)
          .register(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
            role: selectedRole,
            studentId: selectedRole == UserRole.student
                ? _studentIdController.text.trim()
                : null,
            // childName: ref.watch(registrationProvider).role == UserRole.parent
            //     ? _childNameController.text.trim()
            //     : null,
            // childGrade: ref.watch(registrationProvider).role == UserRole.parent
            //     ? _childGradeController.text.trim()
            //     : null,
          );

      if (context.mounted) {
        final school = currentSchool();
        AppSnackBar.success(
          context,
          'Registration successful! Welcome to ${school.name}',
        );

        await Future.delayed(const Duration(milliseconds: 500));
        ref.read(registrationProvider.notifier).clear();
        context.go(RouteNames.login);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Registration failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _nextStep() {
    final role = ref.read(registrationProvider).role;
    final policy = ref.read(registrationPolicyProvider);

    if (widget.step == 0 &&
        (role == null || !policy.allowedRoles.contains(role))) {
      AppSnackBar.warning(context, 'Please select your role');
      return;
    }

    switch (widget.step) {
      case 0:
        context.go(RouteNames.registerDetails);
        break;
      case 1:
        context.go(RouteNames.registerSecurity);
        break;
      case 2:
        if (_termsAccepted) {
          _register();
        } else {
          AppSnackBar.warning(
            context,
            'Please accept the terms and conditions',
          );
        }
        break;
    }
  }

  void _previousStep() {
    if (widget.step > 0) {
      switch (widget.step) {
        case 1:
          context.go(RouteNames.registerRole);
          break;
        case 2:
          context.go(RouteNames.registerDetails);
          break;
      }
    } else {
      context.pop();
    }
  }

  // In your _register() method:

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studentIdController.dispose();
    _childNameController.dispose();
    _childGradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final policy = ref.watch(registrationPolicyProvider);
    final availableRoles = policy.allowedRoles;

    if (!policy.selfRegistrationEnabled || availableRoles.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(RouteNames.login);
          AppSnackBar.warning(context, 'Registration is currently disabled');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final selectedRole = ref.watch(registrationProvider).role;
    if (selectedRole != null && !availableRoles.contains(selectedRole)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(registrationProvider.notifier).clear();
      });
    }

    if (context.isDesktop) {
      return DesktopLayout(
        formKey: _formKey,
        firstNameController: _firstNameController,
        lastNameController: _lastNameController,
        emailController: _emailController,
        phoneController: _phoneController,
        passwordController: _passwordController,
        confirmPasswordController: _confirmPasswordController,
        studentIdController: _studentIdController,
        childNameController: _childNameController,
        childGradeController: _childGradeController,
        selectedRole: selectedRole,
        availableRoles: availableRoles,
        currentStep: widget.step,
        loading: _loading,
        termsAccepted: _termsAccepted,
        obscurePassword: _obscurePassword,
        obscureConfirmPassword: _obscureConfirmPassword,
        onRoleSelected: (role) {
          ref.read(registrationProvider.notifier).setRole(role);
        },
        onTogglePassword: () =>
            setState(() => _obscurePassword = !_obscurePassword),
        onToggleConfirmPassword: () =>
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        onTermsChanged: (value) =>
            setState(() => _termsAccepted = value ?? false),
        onNextStep: _nextStep,
        onPreviousStep: _previousStep,
        onLogin: () => context.go('/login'),
        onChanged: (v) {
          setState(() {});
        },
      );
    } else if (context.isTablet) {
      return TabletLayout(
        formKey: _formKey,
        firstNameController: _firstNameController,
        lastNameController: _lastNameController,
        emailController: _emailController,
        phoneController: _phoneController,
        passwordController: _passwordController,
        confirmPasswordController: _confirmPasswordController,
        studentIdController: _studentIdController,
        childNameController: _childNameController,
        childGradeController: _childGradeController,
        selectedRole: selectedRole,
        availableRoles: availableRoles,
        currentStep: widget.step,
        loading: _loading,
        termsAccepted: _termsAccepted,
        onChanged: (v) {
          setState(() {});
        },
        obscurePassword: _obscurePassword,
        obscureConfirmPassword: _obscureConfirmPassword,
        onRoleSelected: (role) {
          ref.read(registrationProvider.notifier).setRole(role);
        },
        onTogglePassword: () =>
            setState(() => _obscurePassword = !_obscurePassword),
        onToggleConfirmPassword: () =>
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        onTermsChanged: (value) =>
            setState(() => _termsAccepted = value ?? false),
        onNextStep: _nextStep,
        onPreviousStep: _previousStep,
        onLogin: () => context.go('/login'),
      );
    } else {
      return MobileLayout(
        formKey: _formKey,
        firstNameController: _firstNameController,
        lastNameController: _lastNameController,
        emailController: _emailController,
        phoneController: _phoneController,
        passwordController: _passwordController,
        confirmPasswordController: _confirmPasswordController,
        studentIdController: _studentIdController,
        childNameController: _childNameController,
        childGradeController: _childGradeController,
        selectedRole: selectedRole,
        availableRoles: availableRoles,
        currentStep: widget.step,
        onChanged: (v) {
          setState(() {});
        },
        loading: _loading,
        termsAccepted: _termsAccepted,
        obscurePassword: _obscurePassword,
        obscureConfirmPassword: _obscureConfirmPassword,
        onRoleSelected: (role) {
          ref.read(registrationProvider.notifier).setRole(role);
        },
        onTogglePassword: () =>
            setState(() => _obscurePassword = !_obscurePassword),
        onToggleConfirmPassword: () =>
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        onTermsChanged: (value) =>
            setState(() => _termsAccepted = value ?? false),
        onNextStep: _nextStep,
        onPreviousStep: _previousStep,
        onLogin: () => context.go('/login'),
      );
    }
  }
}

// ==================== Mobile Layout ====================

// ==================== Desktop Layout ====================
