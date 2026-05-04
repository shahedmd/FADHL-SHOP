import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/aboutus_controller.dart';
import '../../Widgers/Reuseable/responsive_headermenu.dart';
import '../../Widgers/responsive_layout.dart';
import '../../Admin Panel/Utils/global_colours.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

 IconData _getIconFromString(String iconName) {
  final Map<String, IconData> iconMap = {
    'truckFast':    Icons.local_shipping,
    'shieldHalved': Icons.security,
    'handshake':    Icons.handshake,
    'leaf':         Icons.eco,
    'medal':        Icons.military_tech,
    'gem':          Icons.diamond,
    'heart':        Icons.favorite,
    'star':         Icons.star,
  };
  return iconMap[iconName] ?? Icons.check_circle;
}

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;
    final AboutUsController aboutUsController = Get.put(AboutUsController());

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
                        vertical: 60.0,
                      ),
                      child:
                          isDesktop
                              ? _buildDesktopStory(aboutUsController)
                              : _buildMobileStory(aboutUsController),
                    ),
                  ),

                  ResponsiveLayout(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Why Choose FADHL?',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryGreen,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'The pillars of our premium service.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          Obx(() {
                            if (aboutUsController.isLoading.value) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGold,
                                ),
                              );
                            }
                            if (aboutUsController.coreValues.isEmpty) {
                              return const SizedBox();
                            }

                            return Wrap(
                              spacing: 24,
                              runSpacing: 24,
                              alignment: WrapAlignment.center,
                              children:
                                  aboutUsController.coreValues.map((value) {
                                    return SizedBox(
                                      width: isDesktop ? 350 : double.infinity,
                                      child: _valueCard(
                                        _getIconFromString(
                                          value['iconName'] ?? '',
                                        ),
                                        value['title'] ?? '',
                                        value['description'] ?? '',
                                      ),
                                    );
                                  }).toList(),
                            );
                          }),
                        ],
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
        vertical: isDesktop ? 80 : 50,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.textDark,
        image: DecorationImage(
          image: const NetworkImage(
            'https://images.unsplash.com/photo-1600880292203-757bb62b4baf?q=80&w=2000&auto=format&fit=crop',
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
          Image.asset(
            'assets/logo.webp',
            height: 80,
            errorBuilder: (c, e, s) => const SizedBox(),
          ),
          const SizedBox(height: 20),
          Text(
            'Redefining Luxury E-Commerce',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryGold,
              fontSize: isDesktop ? 42 : 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 600,
            child: Text(
              'Providing safe, reliable, and premium goods to every home in Bangladesh.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.pureWhite.withValues(alpha: 0.8),
                fontSize: isDesktop ? 18 : 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopStory(AboutUsController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=1000&auto=format&fit=crop',
              height: 400,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 1,
          child: _storyTextContent(isDesktop: true, controller: controller),
        ),
      ],
    );
  }

  Widget _buildMobileStory(AboutUsController controller) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=1000&auto=format&fit=crop',
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 30),
        _storyTextContent(isDesktop: false, controller: controller),
      ],
    );
  }

  // 🚀 DYNAMIC STORY TEXT CONTENT
  Widget _storyTextContent({
    required bool isDesktop,
    required AboutUsController controller,
  }) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.storyHeading.value,
            style: const TextStyle(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            controller.storySubtitle.value,
            style: TextStyle(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            controller.storyBody.value,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textDark,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryGold, size: 28),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: AppColors.textDark.withValues(alpha: 0.7),
              height: 1.5,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}