import 'package:get/get.dart';
import '../../controllers/outflow_controller.dart';
import '../../controllers/category_controller.dart';

class OutflowBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutflowController());
    Get.lazyPut(() => CategoryController());
  }
}
