import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Widgers/Reuseable/responsive_headermenu.dart';
import '../../Widgers/responsive_layout.dart';
import '../../Admin Panel/Utils/global_colours.dart';
import '../../Controllers/terms_controller.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;
    // 🚀 INITIALIZE CONTROLLER
    final TermsController termsController = Get.put(TermsController());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          const CustomHeader(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroBanner(isDesktop),

                  ResponsiveLayout(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 40.0,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isDesktop ? 40 : 20),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Obx(() {
                          if (termsController.isLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(60.0),
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGold,
                                ),
                              ),
                            );
                          }
                          if (termsController.terms.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Text(
                                  'No Terms & Conditions available at the moment.',
                                ),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                termsController.terms.map((term) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 32.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          term['title'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          term['content'] ?? '',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: AppColors.textDark
                                                .withValues(alpha: 0.8),
                                            height: 1.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          );
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 60 : 40,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.textDark,
        image: DecorationImage(
          image: const NetworkImage(
            'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?q=80&w=2000&auto=format&fit=crop', // Professional legal/document background
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.textDark.withValues(alpha: 0.85),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.description, color: AppColors.primaryGold, size: 50),
          const SizedBox(height: 20),
          Text(
            'Terms & Conditions',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.pureWhite,
              fontSize: isDesktop ? 42 : 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please read our terms and conditions carefully before using FADHL.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.pureWhite.withValues(alpha: 0.7),
              fontSize: isDesktop ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
