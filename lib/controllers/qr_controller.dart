import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img1;

class QRController extends GetxController {
  var qrResult = ''.obs;
  // var result = ''.obs;
  void scanFromFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final img1.Image? image1 = img1.decodeImage(bytes);

      if (image1 == null) {
        qrResult.value = "Gagal memuat gambar.";
        return;
      }

      LuminanceSource source = RGBLuminanceSource(
        image1.width,
        image1.height,
        image1
            .convert(numChannels: 4)
            .getBytes(order: img1.ChannelOrder.rgba)
            .buffer
            .asInt32List(),
      );
      var bitmap = BinaryBitmap(HybridBinarizer(source));

      var reader = QRCodeReader();
      var result = reader.decode(bitmap);
      print("QR CODE : ${result.text}");

      qrResult.value = result.text;
    } catch (e) {
      qrResult.value = "Gagal membaca QR: ${e.toString()}";
    }
  }
}
