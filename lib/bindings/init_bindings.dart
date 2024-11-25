import 'package:get/get.dart';

import '../controller/admin_controller.dart';
import '../controller/category_controller.dart';
import '../controller/courses_controller.dart';
import '../controller/quiz_controller.dart';
import '../controller/regular_admin_controller.dart';

class InitBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CategoryController());
    Get.lazyPut(() => CoursesController());
    Get.lazyPut(() => RegularAdminController());
    Get.lazyPut(() => AdminController());
    Get.lazyPut(() => QuizController());
  }
}
