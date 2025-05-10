import 'package:flutter/material.dart';
import 'package:flutter_first_app/controllers/auth_controller.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  final AuthController authController = Get.find<AuthController>();
  @override
  RouteSettings? redirect(String? route) {
    if (!authController.isLoggedIn.value) {
      return const RouteSettings(name: '/login');
    }
    return null; // lanjut ke route yang dituju
  }

  // @override
  // int? priority = 0; //
}
