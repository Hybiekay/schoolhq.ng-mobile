import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final _staffIdController = TextEditingController();
  final _childNameController = TextEditingController();
  final _childGradeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;
  bool _termsAccepted = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || !_termsAccepted) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please accept the terms and conditions'),
            backgroundColor: Colors.orange.shade600,
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);

    try {
      await ref
          .read(authProvider.notifier)
          .register(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
            role: ref.watch(registrationProvider).role!,
            studentId: ref.watch(registrationProvider).role == UserRole.student
                ? _studentIdController.text.trim()
                : null,
            staffId: ref.watch(registrationProvider).role == UserRole.staff
                ? _staffIdController.text.trim()
                : null,
            // childName: ref.watch(registrationProvider).role == UserRole.parent
            //     ? _childNameController.text.trim()
            //     : null,
            // childGrade: ref.watch(registrationProvider).role == UserRole.parent
            //     ? _childGradeController.text.trim()
            //     : null,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registration successful! Welcome to SchoolHQ'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        context.go(RouteNames.home); // or context.push(RouteNames.home)
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
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

  void _nextStep() {
    final role = ref.read(registrationProvider).role;

    if (widget.step == 0 && role == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select your role')));
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please accept the terms and conditions'),
            ),
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
    _staffIdController.dispose();
    _childNameController.dispose();
    _childGradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        staffIdController: _staffIdController,
        childNameController: _childNameController,
        childGradeController: _childGradeController,
        selectedRole: ref.watch(registrationProvider).role,
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
        staffIdController: _staffIdController,
        childNameController: _childNameController,
        childGradeController: _childGradeController,
        selectedRole: ref.watch(registrationProvider).role,
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
        staffIdController: _staffIdController,
        childNameController: _childNameController,
        childGradeController: _childGradeController,
        selectedRole: ref.watch(registrationProvider).role,
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
