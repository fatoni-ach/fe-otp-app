import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_first_app/controllers/gd_controller.dart';
import 'package:get/get.dart';

class UploadJsonToDrive extends StatefulWidget {
  const UploadJsonToDrive({super.key});

  @override
  State<UploadJsonToDrive> createState() => _UploadJsonToDriveState();
}

class _UploadJsonToDriveState extends State<UploadJsonToDrive> {
  GdController gdController = Get.find<GdController>();
  String? uploadStatus;

  Future<void> uploadJsonToFolder() async {
    setState(() => uploadStatus = 'Sedang upload...');

    var folderName = 'authenticator';

    final folderId = await gdController.getOrCreateFolder(folderName);
    if (folderId == null) {
      setState(() => uploadStatus = 'Gagal membuat folder.');
      Get.snackbar('Error', 'Gagal membuat folder.');
      return;
    }

    final jsonData = {
      "message": "Hello from Flutter! update",
      "timestamp": DateTime.now().toIso8601String(),
    };

    final Uint8List fileBytes = utf8.encode(json.encode(jsonData));
    final fileName = 'data_${DateTime.now().millisecondsSinceEpoch}.bak';

    final success = await gdController.uploadFile(
      fileBytes,
      fileName,
      folderId,
    );
    if (success) {
      Get.snackbar('Success', 'File berhasil di upload');
    } else {
      Get.snackbar('Error', 'File gagal di upload');
    }
    setState(
      () => uploadStatus = success ? 'Upload berhasil!' : 'Upload gagal.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: uploadJsonToFolder,
          child: const Text('Upload JSON ke Google Drive'),
        ),
        if (uploadStatus != null) Text(uploadStatus!),
      ],
    );
  }
}
