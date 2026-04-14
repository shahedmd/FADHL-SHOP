import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fadhl/Controllers/authcontroller.dart';
import 'package:fadhl/Controllers/cartcontroller.dart';
import 'package:fadhl/Controllers/order_controller.dart';
import 'package:fadhl/Widgers/Reuseable/responsive_headermenu.dart';
import 'package:fadhl/Widgers/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../Admin Panel/Utils/global_colours.dart'; // Ensure AppColors is inside this file

class CartScreen extends StatelessWidget {
  CartScreen({super.key});
  final RxString selectedPayment = 'Cash On Delivery'.obs;
  final RxBool isBillingSameAsShipping = true.obs;
  final RxBool agreedToTerms = false.obs;

  final RxnString selectedDistrict = RxnString();
  final RxnString selectedThana = RxnString();

  final List<String> districts = [
    'Dhaka',
    'Chattogram',
    'Sylhet',
    'Khulna',
    'Rajshahi',
  ];
  final List<String> thanas = [
    'Dhanmondi',
    'Gulshan',
    'Mirpur',
    'Uttara',
    'Mohammadpur',
  ];

  final TextEditingController shippingNameCtrl = TextEditingController();
  final TextEditingController shippingPhoneCtrl = TextEditingController();
  final TextEditingController shippingAddressCtrl = TextEditingController();

  final TextEditingController billingNameCtrl = TextEditingController();
  final TextEditingController billingAddressCtrl = TextEditingController();

  final TextEditingController notesCtrl = TextEditingController();

  // ==========================================
  // AUTO-FILL USER DATA
  // ==========================================
  void _autoFillUserData() {
    final authController = Get.find<AuthController>();
    if (authController.firebaseUser.value != null) {
      // Fetch user data from Firestore in the background
      FirebaseFirestore.instance
          .collection('users')
          .doc(authController.firebaseUser.value!.uid)
          .get()
          .then((doc) {
            if (doc.exists) {
              // Only fill if the fields are currently empty
              if (shippingNameCtrl.text.isEmpty) {
                shippingNameCtrl.text = doc.data()?['name'] ?? '';
              }
              if (shippingPhoneCtrl.text.isEmpty) {
                shippingPhoneCtrl.text = doc.data()?['phone'] ?? '';
              }
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;
    final bool isMobile = screenWidth < 600;

    // Trigger the auto-fill magic the moment the screen builds!
    _autoFillUserData();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // Updated to brand background
      body: Column(
        children: [
          const CustomHeader(),

          Expanded(
            child: Obx(() {
              if (cartController.cartItems.isEmpty) {
                return _buildEmptyCartState();
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    ResponsiveLayout(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12.0 : 16.0,
                          vertical: isMobile ? 20.0 : 30.0,
                        ),
                        child:
                            isDesktop
                                ? _buildDesktopLayout(cartController)
                                : _buildMobileLayout(cartController, isMobile),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // const CustomFooter(), // Optional: Add your footer back if you want
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LAYOUTS
  // ==========================================
  Widget _buildDesktopLayout(CartController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildOrderReviewCard(controller, isMobile: false),
              const SizedBox(height: 20),
              _buildShippingAddressCard(isMobile: false),
              const SizedBox(height: 20),
              _buildBillingAddressCard(isMobile: false),
            ],
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildPaymentMethodCard(isMobile: false),
              const SizedBox(height: 20),
              _buildOrderSummaryCard(controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(CartController controller, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOrderReviewCard(controller, isMobile: isMobile),
        const SizedBox(height: 20),
        _buildShippingAddressCard(isMobile: isMobile),
        const SizedBox(height: 20),
        _buildBillingAddressCard(isMobile: isMobile),
        const SizedBox(height: 20),
        _buildPaymentMethodCard(isMobile: isMobile),
        const SizedBox(height: 20),
        _buildOrderSummaryCard(controller),
      ],
    );
  }

  // ==========================================
  // LEFT COLUMN COMPONENTS
  // ==========================================
  Widget _buildOrderReviewCard(
    CartController controller, {
    required bool isMobile,
  }) {
    return _whiteCard(
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Order review'),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.cartItems.length,
            separatorBuilder: (_, __) => Divider(color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final item = controller.cartItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: isMobile ? 50 : 60,
                      height: isMobile ? 50 : 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.product.images.isNotEmpty
                              ? item.product.images[0]
                              : 'https://via.placeholder.com/60',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 13 : 14,
                              color: AppColors.textDark, // Updated
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Qty: ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),

                              Container(
                                height: 28,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap:
                                          () =>
                                              controller.decreaseQuantity(item),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Icon(Icons.remove, size: 14),
                                      ),
                                    ),
                                    Text(
                                      '${item.quantity.value}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    InkWell(
                                      onTap:
                                          () =>
                                              controller.increaseQuantity(item),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Icon(Icons.add, size: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Spacer(),

                              Text(
                                '৳${(item.product.price * item.quantity.value).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 13 : 14,
                                  color: AppColors.primaryGold, // Updated
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.trashCan,
                        color: Colors.redAccent.shade400,
                        size: 16,
                      ),
                      onPressed:
                          () => controller.removeFromCart(item.product.id),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressCard({required bool isMobile}) {
    return _whiteCard(
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Shipping Address'),
          const SizedBox(height: 20),

          if (isMobile) ...[
            _customTextField(
              'Full Name',
              Icons.person_outline,
              shippingNameCtrl,
            ),
            const SizedBox(height: 16),
            _buildPhoneField(),
            const SizedBox(height: 16),
            _buildDistrictDropdown(),
            const SizedBox(height: 16),
            _buildThanaDropdown(),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _customTextField(
                    'Full Name',
                    Icons.person_outline,
                    shippingNameCtrl,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildPhoneField()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDistrictDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildThanaDropdown()),
              ],
            ),
          ],

          const SizedBox(height: 16),
          _customTextField(
            'House no. / building / street / area',
            Icons.location_on_outlined,
            shippingAddressCtrl,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: shippingPhoneCtrl, // <--- WIRED TO CONTROLLER
      decoration: InputDecoration(
        hintText: 'Phone Number',
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          width: 50,
          child: const Text(
            '+88',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: AppColors.primaryGold,
            width: 2,
          ), // Updated
        ),
      ),
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildDistrictDropdown() {
    return Obx(
      () => DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: _inputDeco('Select District'),
        value: selectedDistrict.value,
        items:
            districts
                .map(
                  (d) => DropdownMenuItem(
                    value: d,
                    child: Text(d, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
        onChanged: (val) => selectedDistrict.value = val,
      ),
    );
  }

  Widget _buildThanaDropdown() {
    return Obx(
      () => DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: _inputDeco('Select Thana (Optional)'),
        value: selectedThana.value,
        items:
            thanas
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(t, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
        onChanged: (val) => selectedThana.value = val,
      ),
    );
  }

  Widget _buildBillingAddressCard({required bool isMobile}) {
    return _whiteCard(
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Billing Address'),
          const SizedBox(height: 12),

          Obx(
            () => InkWell(
              onTap:
                  () =>
                      isBillingSameAsShipping.value =
                          !isBillingSameAsShipping.value,
              child: Row(
                children: [
                  Checkbox(
                    value: isBillingSameAsShipping.value,
                    activeColor: AppColors.primaryGreen, // Updated
                    onChanged: (val) => isBillingSameAsShipping.value = val!,
                  ),
                  const Expanded(
                    child: Text(
                      'Billing address is same as shipping address',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Obx(() {
            if (isBillingSameAsShipping.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  _customTextField(
                    'Billing Full Name',
                    Icons.person_outline,
                    billingNameCtrl,
                  ),
                  const SizedBox(height: 16),
                  _customTextField(
                    'Billing Address Details',
                    Icons.location_city_outlined,
                    billingAddressCtrl,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // RIGHT COLUMN COMPONENTS
  // ==========================================
  Widget _buildPaymentMethodCard({required bool isMobile}) {
    return _whiteCard(
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Payment method'),
          const SizedBox(height: 20),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // 🚀 SMART PAYMENT BOXES (Only COD is available!)
              _paymentBox(
                'Cash On Delivery',
                FontAwesomeIcons.moneyBillWave,
                Colors.green,
                isMobile,
                isAvailable: true,
              ),
              _paymentBox(
                'Online Payment',
                FontAwesomeIcons.creditCard,
                Colors.blue,
                isMobile,
                isAvailable: false,
              ),
              _paymentBox(
                'Bkash',
                FontAwesomeIcons.paperPlane,
                Colors.pink,
                isMobile,
                isAvailable: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentBox(
    String title,
    IconData icon,
    Color iconColor,
    bool isMobile, {
    required bool isAvailable,
  }) {
    return Obx(() {
      final isSelected = selectedPayment.value == title;

      return InkWell(
        onTap: () {
          // 🚀 SHOW UNAVAILABLE MESSAGE
          if (!isAvailable) {
            Get.snackbar(
              'Not Available',
              '$title is currently unavailable. Please select Cash On Delivery.',
              backgroundColor: Colors.orangeAccent,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }
          selectedPayment.value = title;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isMobile ? double.infinity : 180,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            // Gray out the background if it's not available
            color:
                isSelected
                    ? AppColors.primaryGold.withValues(alpha: 0.1) // Updated
                    : (isAvailable
                        ? AppColors.pureWhite
                        : Colors.grey.shade100), // Updated
            border: Border.all(
              color:
                  isSelected
                      ? AppColors.primaryGold
                      : Colors.grey.shade300, // Updated
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              FaIcon(
                icon,
                color: isAvailable ? iconColor : Colors.grey.shade400,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                    color:
                        isAvailable
                            ? AppColors
                                .textDark // Updated
                            : Colors.grey.shade500, // Gray out text
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primaryGold,
                  size: 18,
                ), // Updated
            ],
          ),
        ),
      );
    });
  }

  Widget _buildOrderSummaryCard(CartController controller) {
    return _whiteCard(
      isMobile: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Have any coupon or gift voucher?',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark, // Updated
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _customTextField(
                  'Enter code',
                  Icons.local_offer_outlined,
                  TextEditingController(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen, // Updated
                  foregroundColor: AppColors.primaryGold, // Updated
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {},
                child: const Text('Apply'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),

          _summaryRow('Sub total', controller.subtotal),
          const SizedBox(height: 12),
          _summaryRow('Delivery cost', controller.deliveryCharge),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '৳${controller.grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGold, // Updated
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _sectionTitle('Special notes (Optional)'),
          const SizedBox(height: 12),
          TextField(
            controller: notesCtrl, // <--- WIRED TO CONTROLLER
            maxLines: 2,
            decoration: _inputDeco(
              'Anything we should know?',
            ).copyWith(fillColor: Colors.grey.shade50, filled: true),
          ),

          const SizedBox(height: 24),
          Obx(
            () => InkWell(
              onTap: () => agreedToTerms.value = !agreedToTerms.value,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: agreedToTerms.value,
                      activeColor: AppColors.primaryGreen, // Updated
                      onChanged: (val) => agreedToTerms.value = val!,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'I have read and agree to the Terms and Conditions',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textDark.withValues(alpha: 0.8),
                      ), // Updated
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ==========================================
          // 🚀 THE ULTIMATE PLACE ORDER BUTTON
          // ==========================================
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen, // Updated
                foregroundColor: AppColors.primaryGold, // Updated
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                // 1. Validation
                if (!agreedToTerms.value) {
                  Get.snackbar(
                    'Attention',
                    'Please agree to the Terms and Conditions to proceed.',
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                  return;
                }
                if (shippingNameCtrl.text.isEmpty ||
                    shippingPhoneCtrl.text.isEmpty ||
                    shippingAddressCtrl.text.isEmpty ||
                    selectedDistrict.value == null) {
                  Get.snackbar(
                    'Required Fields',
                    'Please fill in your Name, Phone, District, and Address.',
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                  return;
                }

                // 2. Execute Order
                final orderController = Get.find<OrderController>();

                // 🚀 THE FIX: We capture the returned Order ID!
                String? generatedOrderId = await orderController
                    .placeWebsiteOrder(
                      name: shippingNameCtrl.text,
                      phone: shippingPhoneCtrl.text,
                      district: selectedDistrict.value ?? '',
                      thana: selectedThana.value ?? '',
                      address: shippingAddressCtrl.text,
                      billingName:
                          isBillingSameAsShipping.value
                              ? ''
                              : billingNameCtrl.text,
                      billingAddress:
                          isBillingSameAsShipping.value
                              ? ''
                              : billingAddressCtrl.text,
                      paymentMethod: selectedPayment.value,
                      notes: notesCtrl.text,
                    );

                // 3. Show World-Class Success Dialog with Order ID!
                if (generatedOrderId != null) {
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: AppColors.pureWhite, // Updated
                      child: Container(
                        width: 400,
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(
                                  alpha: 0.1,
                                ), // Updated
                                shape: BoxShape.circle,
                              ),
                              child: const FaIcon(
                                FontAwesomeIcons.circleCheck,
                                color: AppColors.primaryGreen, // Updated
                                size: 45,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Order Confirmed!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color:
                                    AppColors
                                        .textDark, // Updated to brand dark text
                              ),
                            ),
                            const SizedBox(height: 16),

                            Text(
                              'Thank you for shopping with FADHL. Your order has been placed successfully and is being processed.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textDark.withValues(
                                  alpha: 0.8,
                                ), // Updated
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ==========================================
                            // 🚀 NEW: BEAUTIFUL ORDER ID DISPLAY BOX
                            // ==========================================
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold.withValues(
                                  alpha: 0.1,
                                ), // Updated
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primaryGold.withValues(
                                    alpha: 0.5,
                                  ), // Updated
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'YOUR ORDER ID',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    generatedOrderId, // The exact ID from Firebase!
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryGreen, // Updated
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.primaryGreen, // Updated
                                  foregroundColor:
                                      AppColors.primaryGold, // Updated
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(
                                    Get.overlayContext!,
                                  ).pop(); // Close dialog
                                  Get.offAllNamed('/'); // Go home
                                },
                                child: const Text(
                                  'CONTINUE SHOPPING',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    barrierDismissible: false,
                  );
                }
              },
              child: const Text(
                'PLACE ORDER',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UTILITY WIDGETS
  // ==========================================
  Widget _whiteCard({required Widget child, required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite, // Updated
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primaryGold, // Updated
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textDark, // Updated
          ),
        ),
      ],
    );
  }

  Widget _customTextField(
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller, // <--- WIRED UP!
      decoration: _inputDeco(
        hint,
      ).copyWith(prefixIcon: Icon(icon, color: Colors.black38, size: 20)),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: Colors.black45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: AppColors.primaryGold,
          width: 2,
        ), // Updated
      ),
    );
  }

  Widget _summaryRow(String title, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.black54, fontSize: 15),
        ),
        Text(
          '৳${amount.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildEmptyCartState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.05), // Updated
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.cartShopping,
              size: 60,
              color: AppColors.primaryGold.withValues(alpha: 0.5), // Updated
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark, // Updated
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen, // Updated
              foregroundColor: AppColors.primaryGold, // Updated
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Get.offAllNamed('/'),
            icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 16),
            label: const Text(
              'Continue Shopping',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
