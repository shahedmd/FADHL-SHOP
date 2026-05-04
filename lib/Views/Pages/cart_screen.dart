import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fadhl/Controllers/authcontroller.dart';
import 'package:fadhl/Controllers/cartcontroller.dart';
import 'package:fadhl/Controllers/order_controller.dart';
import 'package:fadhl/Widgers/Reuseable/responsive_headermenu.dart';
import 'package:fadhl/Widgers/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Admin Panel/Utils/global_colours.dart';
import '../../Controllers/shipping_areas_controller.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final RxString selectedPayment = 'Cash On Delivery'.obs;
  final RxBool isBillingSameAsShipping = true.obs;
  final RxBool agreedToTerms = false.obs;

  // Initialize the new location controller
  final LocationController locationController = Get.put(LocationController());

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
      FirebaseFirestore.instance
          .collection('users')
          .doc(authController.firebaseUser.value!.uid)
          .get()
          .then((doc) {
            if (doc.exists) {
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

    _autoFillUserData();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
                              color: AppColors.textDark,
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
                                  color: AppColors.primaryGold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: Icon(
                        Icons.delete,
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
      controller: shippingPhoneCtrl,
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
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
        ),
      ),
      keyboardType: TextInputType.phone,
    );
  }

  // ==========================================
  // UPDATED DYNAMIC DROPDOWNS
  // ==========================================
  Widget _buildDistrictDropdown() {
    return Obx(() {
      if (locationController.isLoadingLocations.value) {
        return Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryGold,
              ),
            ),
          ),
        );
      }

      return DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: _inputDeco('Select District'),
        value: locationController.selectedDistrict.value,
        items:
            locationController.districts
                .map(
                  (d) => DropdownMenuItem(
                    value: d,
                    child: Text(d, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
        onChanged: (val) => locationController.onDistrictChanged(val),
      );
    });
  }

  Widget _buildThanaDropdown() {
    return Obx(() {
      final bool isEnabled =
          locationController.selectedDistrict.value != null &&
          locationController.currentThanas.isNotEmpty;

      return DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: _inputDeco(
          isEnabled ? 'Select Thana / Area' : 'Select District First',
        ),
        value: locationController.selectedThana.value,
        items:
            isEnabled
                ? locationController.currentThanas
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList()
                : [],
        // 🚀 THIS IS THE KEY: We call onThanaChanged instead of just updating the value directly!
        onChanged:
            isEnabled ? (val) => locationController.onThanaChanged(val) : null,
      );
    });
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
                    activeColor: AppColors.primaryGreen,
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
              _paymentBox(
                'Cash On Delivery',
                Icons.payments,
                Colors.green,
                isMobile,
                isAvailable: true,
              ),
              _paymentBox(
                'Online Payment',
                Icons.credit_card,
                Colors.blue,
                isMobile,
                isAvailable: false,
              ),
              _paymentBox(
                'Bkash',
                Icons.send,
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
            color:
                isSelected
                    ? AppColors.primaryGold.withValues(alpha: 0.1)
                    : (isAvailable
                        ? AppColors.pureWhite
                        : Colors.grey.shade100),
            border: Border.all(
              color: isSelected ? AppColors.primaryGold : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
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
                        isAvailable ? AppColors.textDark : Colors.grey.shade500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primaryGold,
                  size: 18,
                ),
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
              color: AppColors.textDark,
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
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.primaryGold,
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

          // 🚀 THE MAGIC FIX: Wrapped Subtotal, Delivery Cost, and Grand Total inside Obx()
          // so it instantly reacts when the LocationController's price updates!
          Obx(
            () => Column(
              children: [
                _summaryRow('Sub total', controller.subtotal),
                const SizedBox(height: 12),

                // This will now dynamically update when district/thana is selected!
                _summaryRow('Delivery cost', controller.deliveryCharge),
                const SizedBox(height: 16),

                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '৳${controller.grandTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _sectionTitle('Special notes (Optional)'),
          const SizedBox(height: 12),
          TextField(
            controller: notesCtrl,
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
                      activeColor: AppColors.primaryGreen,
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ==========================================
          // 🚀 PLACE ORDER BUTTON
          // ==========================================
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.primaryGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                // Validation
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
                    locationController.selectedDistrict.value == null) {
                  Get.snackbar(
                    'Required Fields',
                    'Please fill in your Name, Phone, District, and Address.',
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                  return;
                }

                // Execute Order
                final orderController = Get.find<OrderController>();

                String? generatedOrderId = await orderController
                    .placeWebsiteOrder(
                      name: shippingNameCtrl.text,
                      phone: shippingPhoneCtrl.text,
                      district: locationController.selectedDistrict.value ?? '',
                      thana: locationController.selectedThana.value ?? '',
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

                if (generatedOrderId != null) {
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: AppColors.pureWhite,
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
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryGreen,
                                size: 45,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Order Confirmed!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
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
                                ),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primaryGold.withValues(
                                    alpha: 0.5,
                                  ),
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
                                    generatedOrderId,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryGreen,
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
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: AppColors.primaryGold,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(Get.overlayContext!).pop();
                                  Get.offAllNamed('/');
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
        color: AppColors.pureWhite,
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
            color: AppColors.primaryGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textDark,
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
      controller: controller,
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
        borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
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
              color: AppColors.primaryGreen.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart,
              size: 60,
              color: AppColors.primaryGold.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.primaryGold,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Get.offAllNamed('/'),
            icon: const Icon(Icons.arrow_back, size: 16),
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
