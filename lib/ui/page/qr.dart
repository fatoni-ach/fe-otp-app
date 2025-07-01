// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_first_app/controllers/application_controller.dart';
import 'package:flutter_first_app/controllers/cache_controller.dart';
import 'package:flutter_first_app/controllers/qr_controller.dart';
// import 'package:flutter_first_app/controllers/qr_controller.dart';
// import 'package:flutter_zxing/flutter_zxing.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:get/get.dart';
// import 'package:flutter_zxing/flutter_zxing.dart';

class QRViewPage extends StatefulWidget {
  @override
  _QRViewPageState createState() => _QRViewPageState();
}

class _QRViewPageState extends State<QRViewPage> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  // final ApplicationController applicationController =
  //     Get.find<ApplicationController>();

  final CacheController cacheController = Get.find<CacheController>();
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
        ),
        onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
      ),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    // log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('no Permission')));
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    // this.qrController = controller;
    controller.scannedDataStream.listen((scanData) async {
      Get.find<QRController>().qrResult.value = scanData.code ?? '';
      String url = scanData.code ?? '';
      count++;

      controller.dispose();

      Uri uri = Uri.parse(url);

      var secretKey = uri.queryParameters['secret'];
      var issuer = uri.queryParameters['issuer'];
      var algorithm = uri.queryParameters['algorithm'] ?? '';
      var name = uri.pathSegments[0];

      if (secretKey == '' || issuer == '' || name == '') {
        Get.back();
        Get.toNamed("/");

        Get.snackbar("ERROR", "QR CODE IS INVALID");
        return;
      }
      // await controller.pauseCamera();

      if (count <= 1) {
        await cacheController.addApp(name, issuer, secretKey, algorithm);
        await cacheController.loadAppList();
      }
      // applicationController.storeMyTOTP(name, issuer, secret);
      // applicationController.reloadPersonalData();

      Get.back();
    });
  }

  @override
  void dispose() {
    // applicationController.dispose();
    super.dispose();
    cacheController.dispose();
  }
}
