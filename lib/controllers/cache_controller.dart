import 'dart:async';

import 'package:flutter_first_app/controllers/application_controller.dart';
import 'package:flutter_first_app/models/Application.dart';
import 'package:get/get.dart';
import 'package:otp/otp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_controller.dart';

class CacheController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApplicationController appController = Get.find<ApplicationController>();

  var listApp = <Application>[].obs;

  @override
  void onInit() {
    startAutoRefresh();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> saveAppList(List<Application> apps) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = encodeAppllicationList(apps);
    await prefs.setString('application_list', jsonString);
  }

  Future<void> loadAppList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('application_list') ?? '[]';
    final apps = decodeApplicationList(jsonString);

    List<Application> listTemp;
    if (apps.isEmpty) {
      await appController.getPersonalApplication();
      listTemp = appController.listApp.value;

      saveAppList(listTemp);
    } else {
      listTemp = apps;
    }

    for (var i = 0; i < listTemp.length; i++) {
      listTemp[i].kodeOtp = _generateKodeOtp(listTemp[i].secretKey);
    }
    listApp.value = listTemp;
  }

  Future<void> addApp(String name, issuer, secretKey) async {
    final newUser = Application(
      id: 0,
      name: name,
      issuer: issuer,
      secretKey: secretKey,
      kodeOtp: "",
    );
    final temp = listApp.value;

    if (temp == null) {
      return;
    }

    final newList = [...temp, newUser];

    listApp.value = newList;
    await saveAppList(newList);
  }

  Future<void> removeAppByIndex(int index) async {
    final temp = listApp.value;

    if (temp.isEmpty) {
      return;
    }

    temp.removeAt(index);

    await saveAppList(temp);
  }

  String _generateKodeOtp(String secretKey) {
    // Generate TOTP sekarang
    String totp = OTP.generateTOTPCodeString(
      secretKey,
      DateTime.now().millisecondsSinceEpoch,
      interval: 30, // default 30 detik
      length: 6, // jumlah digit OTP
      algorithm: Algorithm.SHA512, // bisa SHA256, SHA512
      // isGoogle: true, // buat kompatibel dengan Google Authenticator
    );

    return totp.toString();
  }

  var currentSecond = 0.obs;
  late Timer timer;

  void startAutoRefresh() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      currentSecond.value = now.second;
      if (now.second == 0 || now.second == 30) {
        loadAppList();
      }
    });
  }
}
