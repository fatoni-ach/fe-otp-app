import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_first_app/controllers/auth_controller.dart';
import 'package:flutter_first_app/models/Application.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// import 'package:flutter_first_app/models/user.dart';

class ApplicationController extends GetxController {
  var listApp = <Application>[].obs;
  var isLoading = true.obs;
  var otpBaseUri = dotenv.env['API_OTP_BASE_URI'] ?? 'http://localhost';
  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    getListApplication();
    // getPersonalApplication();
    startAutoRefresh();
  }

  Future<void> reloadData() async {
    getListApplication();
  }

  Future<void> reloadPersonalData() async {
    getPersonalApplication();
  }

  void getListApplication() async {
    try {
      isLoading(true);
      var response = await http.get(
        Uri.parse('$otpBaseUri/v1/applications?limit=100'),
        headers: {'Authorization': 'Bearer ${authController.token.value}'},
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var listAppData = data['data']['rows'] as List;
        listApp.value =
            listAppData.map((e) => Application.fromJson(e)).toList();
      } else {
        Get.snackbar('Error', 'Failed to load applications');
      }
    } finally {
      isLoading(false);
    }
  }

  void getPersonalApplication() async {
    try {
      isLoading(true);
      var response = await http.get(
        Uri.parse('$otpBaseUri/v1/my/totp?limit=100'),
        headers: {'Authorization': 'Bearer ${authController.token.value}'},
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var listAppData = data['data'] as List;
        listApp.value =
            listAppData.map((e) => Application.fromJson(e)).toList();
      } else {
        Get.snackbar('Error', 'Failed to load applications');
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> store(String name) async {
    try {
      isLoading(true);
      var response = await http.post(
        Uri.parse('$otpBaseUri/v1/applications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.token.value}',
        },
        body: json.encode({'name': name}),
      );
      if (response.statusCode != 200) {
        Get.snackbar('Error', 'Failed to load applications');
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> storeMyTOTP(String name, issuer, secret) async {
    try {
      isLoading(true);
      var response = await http.post(
        Uri.parse('$otpBaseUri/v1/my/totp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.token.value}',
        },
        body: json.encode({'name': name, 'issuer': issuer, 'secret': secret}),
      );
      if (response.statusCode != 200) {
        Get.snackbar('Error', 'Failed to Save TOTP');
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> destroy(int id) async {
    try {
      isLoading(true);
      var response = await http.delete(
        Uri.parse('$otpBaseUri/v1/applications/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.token.value}',
        },
      );
      if (response.statusCode != 200) {
        Get.snackbar('Error', 'Failed to load applications');
      }
    } finally {
      isLoading(false);
    }
  }

  // var data = "Menunggu refresh...".obs;
  var currentSecond = 0.obs;
  late Timer timer;

  void startAutoRefresh() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      currentSecond.value = now.second;
      if (now.second == 0 || now.second == 30) {
        reloadPersonalData();
      }
    });
  }

  @override
  void onClose() {
    timer.cancel();
    super.onClose();
  }
}
