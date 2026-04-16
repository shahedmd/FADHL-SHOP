import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../Widgers/Reuseable/responsive_headermenu.dart';
import '../../Widgers/responsive_layout.dart';
import '../../Admin Panel/Utils/global_colours.dart';
import '../../Controllers/policy_controller.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;
    // 🚀 INITIALIZE CONTROLLER
    final PolicyController policyController = Get.put(PolicyController());

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
                          if (policyController.isLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(60.0),
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGold,
                                ),
                              ),
                            );
                          }
                          if (policyController.policies.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Text(
                                  'No Policies available at the moment.',
                                ),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                policyController.policies.map((policy) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 40.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 4,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryGold,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              policy['title'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.primaryGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          policy['content'] ?? '',
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
            'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?q=80&w=2000&auto=format&fit=crop', // Professional document/policy background
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
          const FaIcon(
            FontAwesomeIcons.shieldHalved,
            color: AppColors.primaryGold,
            size: 50,
          ),
          const SizedBox(height: 20),
          Text(
            'Legal & Policies',
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
            'Learn about our Privacy, Refund, and Cancellation policies.',
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
