import 'package:fadhl/Controllers/authcontroller.dart';
import 'package:fadhl/Controllers/banner_controller.dart';
import 'package:fadhl/Controllers/cartcontroller.dart';
import 'package:fadhl/Controllers/order_controller.dart';
import 'package:fadhl/Controllers/productcontroller.dart';
import 'package:fadhl/Controllers/wishlist_controller.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Auth is the only thing that MUST be permanent and instant
    Get.put<AuthController>(AuthController(), permanent: true);

    // Lazy load everything else so it doesn't freeze the app on load/login
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.lazyPut<BannerController>(() => BannerController(), fenix: true);
    Get.lazyPut<ProductController>(() => ProductController(), fenix: true);
    Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
    Get.lazyPut<WishlistController>(()=> WishlistController(), fenix: true);
  }
}
