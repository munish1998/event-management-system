import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../bloc/auth_bloc/auth_event.dart';
import '../../bloc/auth_bloc/auth_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../../main.dart';
import '../../services/enum.dart';
import '../../services/utils.dart';
import '../../widgets/loading_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final ValueNotifier<bool> isSignUpNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPasswordVisibleNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isEmailLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isGoogleLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> selectedUserTypeNotifier = ValueNotifier<String>('User');

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    isSignUpNotifier.dispose();
    isPasswordVisibleNotifier.dispose();
    isEmailLoadingNotifier.dispose();
    isGoogleLoadingNotifier.dispose();
    selectedUserTypeNotifier.dispose();
    super.dispose();
  }

  void _submitAuth() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();

    if (email.isEmpty) {
      Utils.showFlushBar('Please enter your email address', FlushBarType.warn, context);
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      Utils.showFlushBar('Please enter a valid email address', FlushBarType.warn, context);
      return;
    }

    if (password.isEmpty) {
      Utils.showFlushBar('Please enter your password', FlushBarType.warn, context);
      return;
    }

    if (password.length < 6) {
      Utils.showFlushBar('Password must be at least 6 characters long', FlushBarType.warn, context);
      return;
    }

    if (isSignUpNotifier.value) {
      if (!RegExp(r'[A-Z]').hasMatch(password)) {
        Utils.showFlushBar('Password must contain at least 1 uppercase letter (A-Z)', FlushBarType.warn, context);
        return;
      }
      if (!RegExp(r'[a-z]').hasMatch(password)) {
        Utils.showFlushBar('Password must contain at least 1 lowercase letter (a-z)', FlushBarType.warn, context);
        return;
      }
      if (!RegExp(r'[0-9]').hasMatch(password)) {
        Utils.showFlushBar('Password must contain at least 1 number (0-9)', FlushBarType.warn, context);
        return;
      }
      if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
        Utils.showFlushBar('Password must contain at least 1 special character (!@#\$&*)', FlushBarType.warn, context);
        return;
      }
    }

    if (isSignUpNotifier.value && selectedUserTypeNotifier.value == 'Admin') {
      if (!email.toLowerCase().endsWith('@admin.com')) {
        Utils.showFlushBar(
          'Admin email must end with @admin.com (e.g. yourname@admin.com)',
          FlushBarType.warn,
          context,
        );
        return;
      }
    }

    isEmailLoadingNotifier.value = true;
    isGoogleLoadingNotifier.value = false;

    if (isSignUpNotifier.value) {
      context.read<AuthBloc>().add(
            AuthSignUpRequested(
              email: email,
              password: password,
              name: name.isNotEmpty ? name : email.split('@').first.toUpperCase(),
            ),
          );
    } else {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: email,
              password: password,
            ),
          );
    }
  }

  void _submitGoogleAuth() {
    isGoogleLoadingNotifier.value = true;
    isEmailLoadingNotifier.value = false;
    context.read<AuthBloc>().add(AuthGoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFF5A623);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            left: -100,
            top: MediaQuery.of(context).size.height * 0.18,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    goldColor.withValues(alpha: 0.35),
                    goldColor.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            right: -120,
            top: MediaQuery.of(context).size.height * 0.05,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    goldColor.withValues(alpha: 0.28),
                    goldColor.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    goldColor.withValues(alpha: 0.3),
                    goldColor.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  isEmailLoadingNotifier.value = false;
                  isGoogleLoadingNotifier.value = false;
                  Utils.showFlushBar(state.errorMessage, FlushBarType.error, context);
                } else if (state is Authenticated) {
                  isEmailLoadingNotifier.value = false;
                  isGoogleLoadingNotifier.value = false;
                  Utils.showFlushBar(
                    'Welcome, ${state.user.name} (${state.user.role.name.toUpperCase()})!',
                    FlushBarType.success,
                    context,
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthWrapper()),
                    (route) => false,
                  );
                }
              },
              builder: (context, state) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    physics: const BouncingScrollPhysics(),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isSignUpNotifier,
                      builder: (context, isSignUp, _) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const AppLogoWidget(size: 110),
                            const SizedBox(height: 24),

                            const Text(
                              "Get Started now",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              isSignUp
                                  ? "Create an account to explore events & access passes"
                                  : "Create an account or log in to explore about our app",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 28),

                            if (isSignUp) ...[
                              ValueListenableBuilder<String>(
                                valueListenable: selectedUserTypeNotifier,
                                builder: (context, selectedUserType, _) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildUserTypeRadio("User", selectedUserType == "User", () {
                                        selectedUserTypeNotifier.value = "User";
                                      }),
                                      const SizedBox(width: 24),
                                      _buildUserTypeRadio("Admin", selectedUserType == "Admin", () {
                                        selectedUserTypeNotifier.value = "Admin";
                                      }),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildGoldBorderInput(
                                controller: nameController,
                                hintText: "Full Name",
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 14),
                            ],

                            _buildGoldBorderInput(
                              controller: emailController,
                              hintText: "Email Address",
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),

                            ValueListenableBuilder<bool>(
                              valueListenable: isPasswordVisibleNotifier,
                              builder: (context, isPasswordVisible, _) {
                                return _buildGoldBorderInput(
                                  controller: passwordController,
                                  hintText: "Password",
                                  icon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  isPasswordVisible: isPasswordVisible,
                                  onTogglePassword: () {
                                    isPasswordVisibleNotifier.value = !isPasswordVisible;
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 20),

                            ValueListenableBuilder<bool>(
                              valueListenable: isEmailLoadingNotifier,
                              builder: (context, isEmailLoading, _) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: goldColor,
                                      foregroundColor: Colors.black,
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: (state is AuthLoading) ? null : _submitAuth,
                                    child: (isEmailLoading && state is AuthLoading)
                                        ? const LoadingWidget(color: Colors.black, size: 24)
                                        : Text(
                                            isSignUp ? "Register" : "Login",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 22),

                            Row(
                              children: [
                                Expanded(child: Container(height: 1, color: Colors.white24)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Text(
                                    isSignUp ? "Or register with" : "Or login with",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(child: Container(height: 1, color: Colors.white24)),
                              ],
                            ),
                            const SizedBox(height: 20),

                            ValueListenableBuilder<bool>(
                              valueListenable: isGoogleLoadingNotifier,
                              builder: (context, isGoogleLoading, _) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: (state is AuthLoading) ? null : _submitGoogleAuth,
                                    child: (isGoogleLoading && state is AuthLoading)
                                        ? const LoadingWidget(color: Colors.black, size: 22)
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.network(
                                                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                                width: 20,
                                                height: 20,
                                                errorBuilder: (context, error, stackTrace) => const Icon(
                                                  Icons.g_mobiledata_rounded,
                                                  color: Colors.redAccent,
                                                  size: 28,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              const Text(
                                                "Continue with Google",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: goldColor,
                                  foregroundColor: Colors.black,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  isSignUpNotifier.value = !isSignUpNotifier.value;
                                  selectedUserTypeNotifier.value = 'Admin';
                                },
                                child: Text(
                                  isSignUp ? "Already have an account? Sign In" : "Sign up as Admin",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            GestureDetector(
                              onTap: () {
                                isSignUpNotifier.value = !isSignUpNotifier.value;
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                  text: TextSpan(
                                    text: isSignUp ? "Already have an account? " : "Don't have an account? ",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: isSignUp ? "Sign In" : "Sign Up",
                                        style: const TextStyle(
                                          color: goldColor,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldBorderInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
  }) {
    const goldColor = Color(0xFFF5A623);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: goldColor, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white60, fontSize: 13),
          prefixIcon: Icon(icon, color: goldColor, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: goldColor,
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildUserTypeRadio(String title, bool isSelected, VoidCallback onTap) {
    const goldColor = Color(0xFFF5A623);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? goldColor : Colors.white60,
                width: 2,
              ),
              color: isSelected ? goldColor : Colors.transparent,
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
