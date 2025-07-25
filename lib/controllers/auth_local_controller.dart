import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class AuthLocalController extends GetxController {
  final LocalAuthentication auth = LocalAuthentication();

  // var authStatus = 'Belum diautentikasi'.obs;
  var isLogin = false.obs;

  @override
  void onInit() {
    super.onInit();
    authenticateWithBiometrics(); // Otomatis saat controller diinisialisasi
  }

  Future<void> authenticateWithBiometrics() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      // authStatus.value = 'Biometrik hanya tersedia di Android/iOS';
      Get.snackbar('Info', 'Biometrik hanya tersedia di Android/iOS');
      return;
    }

    try {
      bool canCheck = await auth.canCheckBiometrics;
      bool isSupported = await auth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        // authStatus.value = "Fingerprint tidak tersedia di perangkat ini";
        Get.snackbar('Info', 'Fingerprint tidak tersedia di perangkat ini');

        return;
      }

      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Gunakan sidik jari untuk masuk',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      isLogin.value = didAuthenticate;

      // authStatus.value =
      //     didAuthenticate ? "Autentikasi berhasil!" : "Autentikasi gagal";
    } catch (e) {
      // authStatus.value = "Error: $e";
      isLogin.value = false;
    }
  }
}
