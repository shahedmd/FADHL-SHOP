import 'package:fadhl/Controllers/authcontroller.dart';
import 'package:fadhl/Widgers/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Admin Panel/Utils/global_colours.dart'; // Ensure AppColors is here

// 🚀 1. NEW GETX CONTROLLER: Handles local UI state without setState()
class AuthUIController extends GetxController {
  final RxBool isLogin = true.obs;
  final RxBool isPasswordHidden = true.obs;

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleLogin() {
    isLogin.value = !isLogin.value;
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
  }

  void togglePassword() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }
}

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});
  // Initialize the controllers
  final AuthUIController uiController = Get.put(AuthUIController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: SingleChildScrollView(
          child: ResponsiveLayout(
            child: Container(
              width: isDesktop ? 1100 : double.infinity,
              constraints: BoxConstraints(minHeight: isDesktop ? 500 : 0),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDesktop ? null : AppColors.pureWhite,
                gradient:
                    isDesktop
                        ? const LinearGradient(
                          // 🚀 SWAPPED GRADIENT: Left is White, Right is Green
                          colors: [
                            AppColors.pureWhite,
                            AppColors.pureWhite,
                            AppColors.primaryGreen,
                            AppColors.primaryGreen,
                          ],
                          stops: [0.0, 0.5, 0.5, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                        : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // LEFT SIDE: White Background
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo.webp',
                height: 120,
                errorBuilder: (c, e, s) => const SizedBox(),
              ),
              const SizedBox(height: 24),
              const Text(
                'FADHL',
                style: TextStyle(
                  // Changed to green so it's readable on the white background
                  color: AppColors.primaryGreen,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
        // RIGHT SIDE: Green Background
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
            // Pass 'true' because desktop right side is green
            child: _buildForm(isGreenBg: true),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/logo.webp',
            height: 60,
            errorBuilder: (c, e, s) => const SizedBox(),
          ),
          const SizedBox(height: 16),
          const Text(
            'FADHL',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),
          // Pass 'false' because mobile background is entirely white
          _buildForm(isGreenBg: false),
        ],
      ),
    );
  }

  // 🚀 Added 'isGreenBg' parameter to adapt text/colors dynamically
  Widget _buildForm({required bool isGreenBg}) {
    return Obx(() {
      final isLogin = uiController.isLogin.value;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLogin ? 'Welcome Back' : 'Create Account',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              // Title becomes white on green bg, green on white bg
              color: isGreenBg ? AppColors.pureWhite : AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 32),

          if (!isLogin) ...[
            _customTextField(
              'Full Name',
              Icons.person_outline,
              uiController.nameController,
              false,
              isGreenBg: isGreenBg,
            ),
            const SizedBox(height: 16),
            _customTextField(
              'Phone Number',
              Icons.phone_outlined,
              uiController.phoneController,
              false,
              isPhone: true,
              isGreenBg: isGreenBg,
            ),
            const SizedBox(height: 16),
          ],

          _customTextField(
            'Email Address',
            Icons.email_outlined,
            uiController.emailController,
            false,
            isGreenBg: isGreenBg,
          ),
          const SizedBox(height: 16),
          _customTextField(
            'Password',
            Icons.lock_outline,
            uiController.passwordController,
            true,
            isGreenBg: isGreenBg,
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                // 🚀 Button pops as Gold when on Green Bg, Green when on White Bg
                backgroundColor:
                    isGreenBg ? AppColors.primaryGold : AppColors.primaryGreen,
                foregroundColor:
                    isGreenBg ? AppColors.textDark : AppColors.primaryGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () {
                if (authController.isLoading.value) return;

                if (isLogin) {
                  authController.loginUser(
                    uiController.emailController.text,
                    uiController.passwordController.text,
                  );
                } else {
                  authController.registerUser(
                    uiController.nameController.text,
                    uiController.phoneController.text,
                    uiController.emailController.text,
                    uiController.passwordController.text,
                  );
                }
              },
              child:
                  authController.isLoading.value
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          // Loading indicator matches the text color
                          color:
                              isGreenBg
                                  ? AppColors.textDark
                                  : AppColors.primaryGold,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        isLogin ? 'SIGN IN' : 'SIGN UP',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLogin
                    ? "Don't have an account? "
                    : "Already have an account? ",
                style: TextStyle(
                  // Soft white on green bg, dark text on white bg
                  color:
                      isGreenBg
                          ? Colors.white70
                          : AppColors.textDark.withValues(alpha: 0.7),
                ),
              ),
              InkWell(
                onTap: uiController.toggleLogin,
                child: Text(
                  isLogin ? 'Sign Up' : 'Sign In',
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _customTextField(
    String hint,
    IconData icon,
    TextEditingController controller,
    bool isPassword, {
    bool isPhone = false,
    required bool isGreenBg, // 🚀 Requires background context to adjust styling
  }) {
    return Obx(() {
      final isHidden = uiController.isPasswordHidden.value;

      return TextField(
        controller: controller,
        obscureText: isPassword ? isHidden : false,
        keyboardType:
            isPhone ? TextInputType.phone : TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: hint,
          // Icons become bright green if on green bg, standard grey on white bg
          prefixIcon: Icon(
            icon,
            color: isGreenBg ? AppColors.primaryGreen : Colors.black38,
            size: 20,
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      isHidden ? Icons.visibility_off : Icons.visibility,
                      color:
                          isGreenBg ? AppColors.primaryGreen : Colors.black38,
                      size: 20,
                    ),
                    onPressed: uiController.togglePassword,
                  )
                  : null,
          filled: true,
          // Solid white looks amazing as an input field on a green background
          fillColor: isGreenBg ? AppColors.pureWhite : Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      );
    });
  }
}