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

  UserRole? _selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;
  int _currentStep = 0;
  bool _termsAccepted = false;
  @override
  void initState() {
    _currentStep = widget.step;
    super.initState();
  }

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
            role: _selectedRole!,
            studentId: _selectedRole == UserRole.student
                ? _studentIdController.text.trim()
                : null,
            staffId: _selectedRole == UserRole.staff
                ? _staffIdController.text.trim()
                : null,
            // childName: _selectedRole == UserRole.parent
            //     ? _childNameController.text.trim()
            //     : null,
            // childGrade: _selectedRole == UserRole.parent
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
    if (_currentStep == 0) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select your role'),
            backgroundColor: Colors.orange.shade600,
          ),
        );
        return;
      }
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    if (_currentStep < 2) {
      final nextStep = _currentStep + 1;
      // Navigate to the corresponding route
      switch (nextStep) {
        case 1:
          context.go(RouteNames.registerDetails);
          print(RouteNames.registerDetails);
          print(nextStep);
          break;
        case 2:
          context.go(RouteNames.registerSecurity);
          print(RouteNames.registerSecurity);

          break;
      }
    } else if (_formKey.currentState!.validate() && _termsAccepted) {
      _register();
    } else if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the terms and conditions'),
          backgroundColor: Colors.orange.shade600,
        ),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      final prevStep = _currentStep - 1;
      // Navigate to the corresponding route
      switch (prevStep) {
        case 0:
          context.go(RouteNames.registerRole);
          break;
        case 1:
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
    if (_currentStep != widget.step) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _currentStep = widget.step;
        });
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
        staffIdController: _staffIdController,
        childNameController: _childNameController,
        childGradeController: _childGradeController,
        selectedRole: _selectedRole,
        currentStep: _currentStep,
        loading: _loading,
        termsAccepted: _termsAccepted,
        obscurePassword: _obscurePassword,
        obscureConfirmPassword: _obscureConfirmPassword,
        onRoleSelected: (role) => setState(() => _selectedRole = role),
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
        selectedRole: _selectedRole,
        currentStep: _currentStep,
        loading: _loading,
        termsAccepted: _termsAccepted,
        onChanged: (v) {
          setState(() {});
        },
        obscurePassword: _obscurePassword,
        obscureConfirmPassword: _obscureConfirmPassword,
        onRoleSelected: (role) => setState(() => _selectedRole = role),
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
        selectedRole: _selectedRole,
        currentStep: _currentStep,
        onChanged: (v) {
          setState(() {});
        },
        loading: _loading,
        termsAccepted: _termsAccepted,
        obscurePassword: _obscurePassword,
        obscureConfirmPassword: _obscureConfirmPassword,
        onRoleSelected: (role) => setState(() => _selectedRole = role),
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
