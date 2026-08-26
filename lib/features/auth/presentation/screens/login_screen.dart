import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../main.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final isSignUpNotifier = ValueNotifier<bool>(false);

    void submitLogin(String email, String password) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(email: email, password: password),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.redAccent,
                ),
              );
            } else if (state is Authenticated) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthWrapper()),
                (route) => false,
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const AppLogoWidget(size: 84),
                  const SizedBox(height: 16),
                  Text(
                    'allevents',
                    style: AppTypography.headingLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Organizer & Event Portal',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primaryDark,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 28),

                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        ValueListenableBuilder<bool>(
                          valueListenable: isSignUpNotifier,
                          builder: (context, isSignUp, child) {
                            return Container(
                              height: 44,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.borderLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          isSignUpNotifier.value = false,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: !isSignUp
                                              ? AppColors.surface
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: !isSignUp
                                              ? [
                                                  BoxShadow(
                                                    color: AppColors.primary
                                                        .withValues(
                                                          alpha: 0.08,
                                                        ),
                                                    blurRadius: 6,
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Sign In',
                                            style: AppTypography.button
                                                .copyWith(
                                                  fontSize: 13,
                                                  color: !isSignUp
                                                      ? AppColors.primary
                                                      : AppColors.textMuted,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          isSignUpNotifier.value = true,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSignUp
                                              ? AppColors.surface
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: isSignUp
                                              ? [
                                                  BoxShadow(
                                                    color: AppColors.primary
                                                        .withValues(
                                                          alpha: 0.08,
                                                        ),
                                                    blurRadius: 6,
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Create Account',
                                            style: AppTypography.button
                                                .copyWith(
                                                  fontSize: 13,
                                                  color: isSignUp
                                                      ? AppColors.primary
                                                      : AppColors.textMuted,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        CustomTextField(
                          controller: emailController,
                          labelText: 'Email Address',
                          hintText: 'user@domain.com or admin@admin.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: passwordController,
                          labelText: 'Password',
                          hintText: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 24),

                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return CustomButton(
                              label: 'Continue',
                              isLoading: state is AuthLoading,
                              icon: Icons.arrow_forward_rounded,
                              gradient: AppColors.primaryGradient,
                              onPressed: () {
                                submitLogin(
                                  emailController.text,
                                  passwordController.text,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '⚡ Quick Role Selector Demo',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                label: 'User Role',
                                isOutlined: true,
                                icon: Icons.person_outline,
                                onPressed: () {
                                  emailController.text = 'sarah@user.com';
                                  passwordController.text = 'password123';
                                  submitLogin('sarah@user.com', 'password123');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                label: 'Admin Role',
                                icon: Icons.admin_panel_settings_outlined,
                                gradient: AppColors.primaryGradient,
                                onPressed: () {
                                  emailController.text = 'alex@admin.com';
                                  passwordController.text = 'admin123';
                                  submitLogin('alex@admin.com', 'admin123');
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
