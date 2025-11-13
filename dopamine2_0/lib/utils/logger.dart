import 'package:get/get.dart';

class AppLogger {
  static void info(String msg) => Get.log('ℹ️ $msg');
  static void warn(String msg) => Get.log('⚠️ $msg');
  static void error(String msg) => Get.log('❌ $msg');
}
