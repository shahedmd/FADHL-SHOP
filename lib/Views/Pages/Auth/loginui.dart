import 'package:fadhl/Controllers/authcontroller.dart';
import 'package:fadhl/Widgers/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

// 🚀 2. STATELESS WIDGET: Replaced StatefulWidget
class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final Color brandGreen = const Color(0xFF0A1F13);
  final Color brandGold = const Color(0xFFCEAB5F);

  // Initialize the controllers
  final AuthUIController uiController = Get.put(AuthUIController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          child: ResponsiveLayout(
            child: Container(
              width: isDesktop ? 1100 : double.infinity,
              constraints: BoxConstraints(minHeight: isDesktop ? 500 : 0),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // 🚀 3. PERFORMANCE FIX: A hard-stop gradient creates the two-tone background instantly.
                // No IntrinsicHeight needed, no 'stretch' needed!
                color: isDesktop ? null : Colors.white,
                gradient:
                    isDesktop
                        ? LinearGradient(
                          colors: [
                            brandGreen,
                            brandGreen,
                            Colors.white,
                            Colors.white,
                          ],
                          stops: const [
                            0.0,
                            0.5,
                            0.5,
                            1.0,
                          ], // Exactly 50/50 split
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
      // Default crossAxisAlignment is center, so children will just center vertically
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Takes minimal height
            children: [
              Image.asset(
                'assets/logo.webp',
                height: 120,
                errorBuilder: (c, e, s) => const SizedBox(),
              ),
              const SizedBox(height: 24),
              Text(
                'FADHL',
                style: TextStyle(
                  color: brandGold,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
            child: _buildForm(),
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
          Text(
            'FADHL',
            style: TextStyle(
              color: brandGreen,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),
          _buildForm(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    // 🚀 4. OBX WRAPPER: Reactively builds the form based on state changes.
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
              color: brandGreen,
            ),
          ),
          const SizedBox(height: 32),

          if (!isLogin) ...[
            _customTextField(
              'Full Name',
              Icons.person_outline,
              uiController.nameController,
              false,
            ),
            const SizedBox(height: 16),
            _customTextField(
              'Phone Number',
              Icons.phone_outlined,
              uiController.phoneController,
              false,
              isPhone: true,
            ),
            const SizedBox(height: 16),
          ],

          _customTextField(
            'Email Address',
            Icons.email_outlined,
            uiController.emailController,
            false,
          ),
          const SizedBox(height: 16),
          _customTextField(
            'Password',
            Icons.lock_outline,
            uiController.passwordController,
            true,
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandGreen,
                foregroundColor: brandGold,
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
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Color(0xFFCEAB5F),
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
                style: const TextStyle(color: Colors.black54),
              ),
              InkWell(
                onTap: uiController.toggleLogin,
                child: Text(
                  isLogin ? 'Sign Up' : 'Sign In',
                  style: TextStyle(
                    color: brandGold,
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
  }) {
    // Only elements that need independent observation are wrapped in Obx.
    return Obx(() {
      final isHidden = uiController.isPasswordHidden.value;

      return TextField(
        controller: controller,
        obscureText: isPassword ? isHidden : false,
        keyboardType:
            isPhone ? TextInputType.phone : TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.black38, size: 20),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      isHidden ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black38,
                      size: 20,
                    ),
                    onPressed: uiController.togglePassword,
                  )
                  : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      );
    });
  }
}