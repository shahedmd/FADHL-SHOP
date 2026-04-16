import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Admin Panel/Utils/global_colours.dart';
import '../../Widgers/Reuseable/responsive_headermenu.dart';
import '../../Widgers/responsive_layout.dart';
import '../../Controllers/faq_controller.dart'; // 🚀 IMPORT CONTROLLER

class FaqScreen extends StatelessWidget {
  FaqScreen({super.key});

  // 🚀 INITIALIZE CONTROLLER
  final FaqController faqController = Get.put(FaqController());

  // ==========================================
  // WHATSAPP REDIRECT (Support)
  // ==========================================
  Future<void> _contactSupport() async {
    const String phoneNumber = "880132540925";
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent('Hello FADHL Support, I have a question regarding...')}",
    );
    try {
      await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
    } catch (e) {
      Get.snackbar('Error', 'Could not open WhatsApp.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          const CustomHeader(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(isDesktop),

                  ResponsiveLayout(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 40.0,
                      ),
                      child:
                          isDesktop
                              ? _buildDesktopLayout()
                              : _buildMobileLayout(),
                    ),
                  ),

                  ResponsiveLayout(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: _buildContactSupportCard(isDesktop),
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

  // ==========================================
  // LAYOUTS
  // ==========================================
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildCategorySidebar()),
        const SizedBox(width: 60),
        Expanded(flex: 7, child: _buildFaqList()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryDropdown(),
        const SizedBox(height: 30),
        _buildFaqList(),
      ],
    );
  }

  // ==========================================
  // COMPONENTS
  // ==========================================
  Widget _buildHeroSection(bool isDesktop) {
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
            'https://images.unsplash.com/photo-1557425955-df376b5903c8?q=80&w=2000&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.textDark.withValues(alpha: 0.9),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        children: [
          const FaIcon(
            FontAwesomeIcons.circleQuestion,
            color: AppColors.primaryGold,
            size: 50,
          ),
          const SizedBox(height: 20),
          Text(
            'How can we help you?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.pureWhite,
              fontSize: isDesktop ? 42 : 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Find answers to frequently asked questions about FADHL.',
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

  Widget _buildCategorySidebar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 20),

          Obx(() {
            if (faqController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              );
            }
            return Column(
              children:
                  faqController.categories.map((category) {
                    final isSelected =
                        faqController.selectedCategory.value == category;
                    return InkWell(
                      onTap:
                          () => faqController.selectedCategory.value = category,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primaryGreen.withValues(
                                    alpha: 0.05,
                                  )
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primaryGold
                                    : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? AppColors.primaryGreen
                                    : AppColors.textDark,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return SizedBox(
      height: 45,
      child: Obx(() {
        if (faqController.isLoading.value) return const SizedBox();
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: faqController.categories.length,
          itemBuilder: (context, index) {
            final category = faqController.categories[index];
            final isSelected = faqController.selectedCategory.value == category;
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ChoiceChip(
                label: Text(category),
                selected: isSelected,
                selectedColor: AppColors.primaryGreen,
                backgroundColor: AppColors.pureWhite,
                labelStyle: TextStyle(
                  color:
                      isSelected ? AppColors.primaryGold : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color:
                        isSelected
                            ? AppColors.primaryGreen
                            : Colors.grey.shade300,
                  ),
                ),
                onSelected: (selected) {
                  if (selected) faqController.selectedCategory.value = category;
                },
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildFaqList() {
    return Obx(() {
      if (faqController.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(color: AppColors.primaryGold),
          ),
        );
      }

      final filteredFaqs =
          faqController.selectedCategory.value == 'All'
              ? faqController.faqs
              : faqController.faqs
                  .where(
                    (faq) =>
                        faq['category'] == faqController.selectedCategory.value,
                  )
                  .toList();

      if (filteredFaqs.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(40.0),
          child: Center(
            child: Text(
              'No FAQs available in this category.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredFaqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final faq = filteredFaqs[index];

          return Container(
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: AppColors.primaryGold,
                collapsedIconColor: AppColors.primaryGreen,
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                title: Text(
                  faq['q'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryGreen,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 24,
                    ),
                    child: Text(
                      faq['a'] ?? '',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildContactSupportCard(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
      ),
      child:
          isDesktop
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _contactContent(isDesktop),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _contactContent(isDesktop),
              ),
    );
  }

  List<Widget> _contactContent(bool isDesktop) {
    return [
      Column(
        crossAxisAlignment:
            isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          const Text(
            'Still have questions?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our premium support team is here to help you 24/7.',
            style: TextStyle(
              color: AppColors.textDark.withValues(alpha: 0.7),
              fontSize: 15,
            ),
          ),
        ],
      ),
      if (!isDesktop) const SizedBox(height: 24),
      SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            elevation: 0,
          ),
          onPressed: _contactSupport,
          icon: const FaIcon(
            FontAwesomeIcons.whatsapp,
            color: Colors.white,
            size: 20,
          ),
          label: const Text(
            'Chat on WhatsApp',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    ];
  }
}