// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_first_app/controllers/application_controller.dart';
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
  final ApplicationController applicationController =
      Get.find<ApplicationController>();

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: QRView(
    //     key: qrKey,
    //     onQRViewCreated: _onQRViewCreated,
    //     overlay: QrScannerOverlayShape(
    //       borderColor: Colors.green,
    //       borderRadius: 10,
    //       borderLength: 30,
    //       borderWidth: 10,
    //       cutOutSize: 250,
    //     ),
    //   ),
    // );
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          // cutOutSize: scanArea,
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
    controller.scannedDataStream.listen((scanData) {
      Get.find<QRController>().qrResult.value = scanData.code ?? '';
      controller.dispose();
      String url = scanData.code ?? '';

      Uri uri = Uri.parse(url);

      var secret = uri.queryParameters['secret'];
      var issuer = uri.queryParameters['issuer'];
      var name = uri.pathSegments[0];

      if (secret == '' || issuer == '' || name == '') {
        Get.back();
        Get.toNamed("/");

        Get.snackbar("ERROR", "QR CODE IS INVALID");
        return;
      }

      applicationController.storeMyTOTP(name, issuer, secret);
      applicationController.reloadPersonalData();

      // print("SECRET : $secret");
      // print("ISSUER : $issuer");
      // print("EMAIL : $email");
      // print("QR CODE : ${scanData.code}");
      // Get.snackbar("success", scanData.code ?? "");
      // controller.pauseCamera();
      // Get.back(result: "success");
      Get.back();
      // Get.back();
      // Get.toNamed("/");
    });
  }

  @override
  void dispose() {
    qrController?.dispose();
    applicationController.dispose();
    super.dispose();
  }
}
