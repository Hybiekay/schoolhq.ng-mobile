import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/enum/user_role.dart';
import 'package:schoolhq_ng/views/auth/register/widget/role_card.dart';
import 'package:schoolhq_ng/views/auth/register/widget/role_specific_fields.dart';
import 'package:schoolhq_ng/views/auth/register/widget/step_indicator.dart';
import 'package:schoolhq_ng/views/auth/register/widget/terms_check_box.dart';
import 'package:schoolhq_ng/widget/app_text_field.dart';

class TabletLayout extends StatelessWidget {
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

  const TabletLayout({
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
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppImages.logo, height: 48, width: 48),
                      const SizedBox(width: 16),
                      Text(
                        'SchoolHQ',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Create Your Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Join thousands of students, teachers, and parents using SchoolHQ',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Step Indicator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: StepIndicator(
                      currentStep: currentStep,
                      totalSteps: 3,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Form Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
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
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: onLogin,
                        child: Text(
                          'Sign In Here',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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
        Text(
          'Who are you joining as?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Choose the role that best describes how you\'ll use SchoolHQ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Role Selection Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
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
          width: 300,
          height: 52,
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
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20),
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
        Text(
          'Personal Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Please provide your personal information',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Form Fields
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: firstNameController,
                label: 'First Name *',
                hintText: 'Enter first name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                controller: lastNameController,
                label: 'Last Name *',
                hintText: 'Enter last name',
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
                hintText: 'Enter your email',
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
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                controller: phoneController,
                label: 'Phone Number *',
                hintText: 'Enter your phone',
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 52,
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
                      'Back',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 150,
              height: 52,
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
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
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
        Text(
          'Account Security',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Create a secure password for your account',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Password Fields
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: passwordController,
                label: 'Password *',
                hintText: 'Create a strong password',
                icon: Icons.lock_outline,
                obscureText: obscurePassword,
                showObscureToggle: true,
                onChanged: onChanged,

                onToggleObscure: onTogglePassword,
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
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                controller: confirmPasswordController,
                label: 'Confirm Password *',
                hintText: 'Confirm your password',
                icon: Icons.lock_outline,
                onChanged: onChanged,
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

        const SizedBox(height: 24),

        // Password Requirements
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password Requirements:',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: _buildPasswordRequirementsTablet(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 52,
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
                      'Back',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 200,
              height: 52,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.check, size: 20),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildPasswordRequirementsTablet() {
    final password = passwordController.text;
    final requirements = [
      {'text': 'At least 8 characters', 'met': password.length >= 8},
      {
        'text': 'One uppercase letter',
        'met': RegExp(r'[A-Z]').hasMatch(password),
      },
      {
        'text': 'One lowercase letter',
        'met': RegExp(r'[a-z]').hasMatch(password),
      },
      {'text': 'One number', 'met': RegExp(r'\d').hasMatch(password)},
    ];

    return requirements.map((req) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            req['met'] as bool ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
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
