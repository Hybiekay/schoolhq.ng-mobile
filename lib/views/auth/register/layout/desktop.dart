import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/enum/user_role.dart';
import 'package:schoolhq_ng/views/auth/register/widget/password_strength_indicator.dart';
import 'package:schoolhq_ng/views/auth/register/widget/role_card.dart';
import 'package:schoolhq_ng/views/auth/register/widget/role_specific_fields.dart';
import 'package:schoolhq_ng/views/auth/register/widget/terms_check_box.dart';
import 'package:schoolhq_ng/widget/app_text_field.dart';
import 'package:schoolhq_ng/widget/feature_item.dart';

class DesktopLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController studentIdController;
  final TextEditingController staffIdController;
  final TextEditingController childNameController;
  final TextEditingController childGradeController;
  final UserRole? selectedRole;
  final int currentStep;
  final bool loading;
  final bool termsAccepted;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final Function(UserRole) onRoleSelected;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onNextStep;
  final VoidCallback onPreviousStep;
  final VoidCallback onLogin;
  final void Function(String?)? onChanged;

  const DesktopLayout({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.studentIdController,
    required this.staffIdController,
    required this.childNameController,
    required this.childGradeController,
    required this.selectedRole,
    required this.currentStep,
    required this.loading,
    required this.termsAccepted,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onRoleSelected,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onTermsChanged,
    required this.onNextStep,
    required this.onPreviousStep,
    required this.onLogin,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Left Panel - Branding & Info
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Container(
                color: AppColors.primary.withOpacity(0.03),
                padding: const EdgeInsets.all(60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and Brand
                    Row(
                      children: [
                        Image.asset(AppImages.logo, height: 40, width: 40),
                        const SizedBox(width: 12),
                        Text(
                          'SchoolHQ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // Hero Text
                    Text(
                      'Join Our Educational Community',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade900,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Create your account to access personalized learning experiences, track progress, and connect with your educational community.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Features
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FeatureItem(
                          icon: Icons.school_outlined,
                          title: 'Personalized Dashboard',
                          description:
                              'Access courses, assignments, and grades tailored to your role',
                        ),
                        const SizedBox(height: 20),
                        FeatureItem(
                          icon: Icons.timeline_outlined,
                          title: 'Progress Tracking',
                          description:
                              'Monitor academic progress with detailed analytics and reports',
                        ),
                        const SizedBox(height: 20),
                        FeatureItem(
                          icon: Icons.group_outlined,
                          title: 'Community Connection',
                          description:
                              'Connect with teachers, students, and parents in one platform',
                        ),
                        const SizedBox(height: 20),
                        FeatureItem(
                          icon: Icons.security_outlined,
                          title: 'Secure & Private',
                          description:
                              'Your data is protected with enterprise-grade security',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Stats/Testimonials
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '50K+',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Active Users',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade200,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '200+',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Schools',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade200,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '99%',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Satisfaction',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Panel - Registration Form
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: onPreviousStep,
                        tooltip: 'Back',
                      ),
                      const Spacer(),
                      Text(
                        'Step ${currentStep + 1}/3',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Text(
                    _getStepTitle(currentStep),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _getStepSubtitle(currentStep),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),

                  const SizedBox(height: 40),

                  // Step Progress
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: LinearProgressIndicator(
                      value: (currentStep + 1) / 3,
                      backgroundColor: Colors.grey.shade200,
                      color: AppColors.primary,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Role Selection',
                        style: TextStyle(
                          color: currentStep >= 0
                              ? AppColors.primary
                              : Colors.grey.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Personal Details',
                        style: TextStyle(
                          color: currentStep >= 1
                              ? AppColors.primary
                              : Colors.grey.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Account Security',
                        style: TextStyle(
                          color: currentStep >= 2
                              ? AppColors.primary
                              : Colors.grey.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: formKey,
                      child: _buildStepContent(context),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: onLogin,
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Footer Text
                  Text(
                    'By creating an account, you agree to our Terms of Service and Privacy Policy. Your information is secure and will only be used for educational purposes.',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Select Your Role';
      case 1:
        return 'Personal Information';
      case 2:
        return 'Account Security';
      default:
        return 'Create Account';
    }
  }

  String _getStepSubtitle(int step) {
    switch (step) {
      case 0:
        return 'Choose how you\'ll use SchoolHQ to customize your experience';
      case 1:
        return 'Tell us about yourself so we can personalize your dashboard';
      case 2:
        return 'Create a secure password to protect your account';
      default:
        return 'Complete your registration';
    }
  }

  Widget _buildStepContent(BuildContext context) {
    switch (currentStep) {
      case 0:
        return _buildStep1(context);
      case 1:
        return _buildStep2(context);
      case 2:
        return _buildStep3(context);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1(BuildContext context) {
    return Column(
      children: [
        // Role Cards Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1,
          children: UserRole.values.map((role) {
            return RoleCard(
              role: role,
              isSelected: selectedRole == role,
              onTap: () => onRoleSelected(role),
            );
          }).toList(),
        ),

        const SizedBox(height: 40),

        // Next Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: selectedRole == null ? null : onNextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue to Personal Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded, size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(BuildContext context) {
    return Column(
      children: [
        // Form Grid
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: firstNameController,
                    label: 'First Name *',
                    hintText: 'Enter your first name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: AppTextField(
                    controller: lastNameController,
                    label: 'Last Name *',
                    hintText: 'Enter your last name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: emailController,
                    label: 'Email Address *',
                    hintText: 'Enter your email address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: AppTextField(
                    controller: phoneController,
                    label: 'Phone Number *',
                    hintText: 'Enter your phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number is required';
                      }
                      if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),

        // Role-specific fields
        RoleSpecificFields(
          selectedRole: selectedRole,
          studentIdController: studentIdController,
          staffIdController: staffIdController,
          childNameController: childNameController,
          childGradeController: childGradeController,
        ),

        const SizedBox(height: 40),

        // Navigation Buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: onPreviousStep,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_back, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Back to Role ',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: onNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue to Security',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3(BuildContext context) {
    return Column(
      children: [
        // Password Fields
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: passwordController,
                label: 'Create Password *',
                hintText: 'Enter a strong password',
                icon: Icons.lock_outline,
                obscureText: obscurePassword,
                showObscureToggle: true,
                onToggleObscure: onTogglePassword,
                onChanged: onChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  if (!RegExp(
                    r'(?=.*[A-Z])(?=.*[a-z])(?=.*\d)',
                  ).hasMatch(value)) {
                    return 'Include uppercase, lowercase & number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: AppTextField(
                controller: confirmPasswordController,
                label: 'Confirm Password *',
                hintText: 'Re-enter your password',
                icon: Icons.lock_outline,
                obscureText: obscureConfirmPassword,
                showObscureToggle: true,
                onToggleObscure: onToggleConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Password Strength Indicator
        PasswordStrengthIndicator(password: passwordController.text),

        const SizedBox(height: 20),

        // Password Requirements
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password must include:',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: _buildPasswordRequirementsDesktop(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Terms and Conditions
        TermsCheckbox(
          value: termsAccepted,
          onChanged: onTermsChanged,
          onTermsTap: () => context.push('/terms'),
          onPrivacyTap: () => context.push('/privacy'),
        ),

        const SizedBox(height: 40),

        // Navigation Buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: onPreviousStep,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_back, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Back to Details',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: loading ? null : onNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                            Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle_outlined, size: 22),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildPasswordRequirementsDesktop() {
    final password = passwordController.text;
    final requirements = [
      {'text': 'Minimum 8 characters', 'met': password.length >= 8},
      {
        'text': 'At least one uppercase letter',
        'met': RegExp(r'[A-Z]').hasMatch(password),
      },
      {
        'text': 'At least one lowercase letter',
        'met': RegExp(r'[a-z]').hasMatch(password),
      },
      {'text': 'At least one number', 'met': RegExp(r'\d').hasMatch(password)},
      {
        'text': 'At least one special character',
        'met': RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
      },
    ];

    return requirements.map((req) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            req['met'] as bool ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: req['met'] as bool ? Colors.green : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            req['text'] as String,
            style: TextStyle(
              color: req['met'] as bool
                  ? Colors.green.shade700
                  : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      );
    }).toList();
  }
}
