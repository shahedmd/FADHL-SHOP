import 'package:fadhl/Controllers/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../Admin Panel/Utils/global_colours.dart'; // Ensure AppColors is inside this file

void showTrackOrderDialog() {
  final TextEditingController trackCtrl = TextEditingController();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.pureWhite, // Updated
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(
              FontAwesomeIcons.magnifyingGlassLocation,
              size: 40,
              color: AppColors.primaryGreen, // Updated
            ),
            const SizedBox(height: 24),
            const Text(
              'Track Your Order',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark, // Updated to brand dark text
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your Order ID below to see your current shipping status.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: trackCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. ORD-144-8492',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primaryGold, // Updated
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen, // Updated
                  foregroundColor: AppColors.primaryGold, // Updated
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  final OrderController oc = Get.find<OrderController>();
                  oc.trackOrder(trackCtrl.text); // Trigger the logic!
                },
                child: const Text(
                  'TRACK ORDER',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
