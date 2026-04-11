import 'package:fadhl/Widgers/Reuseable/category_selector.dart';
import 'package:fadhl/Widgers/Reuseable/product_grid.dart';
import 'package:fadhl/Widgers/Reuseable/responsive_bottomnavbar.dart';
import 'package:fadhl/Widgers/Reuseable/responsive_headermenu.dart';
import 'package:fadhl/Widgers/Reuseable/responsiveslider.dart';
import 'package:fadhl/Widgers/responsive_layout.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 1. THE STICKY HEADER
          CustomHeader(),

          // 2. THE SCROLLABLE BODY
          Expanded(
            child: SingleChildScrollView(
              child: ResponsiveLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SLIDING BANNERS ---
                    PromoCarousel(),

                    // --- PREMIUM CATEGORY TABS ---
                    CategorySelector(),

                    // --- THE PRODUCT GRID ---
                    const ProductGrid(),

                    const SizedBox(height: 60), // Bottom breathing room
                    CustomFooter()
                  ],
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}
