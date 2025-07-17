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

  void loadFiles() async {
    final files = await gdController.listDriveFiles();
    for (var file in files) {
      print('File: ${file['name']} (${file['id']})');
      if (file['name'] == 'data.bak') {
        final content = await gdController.downloadFileContent(file['id']);
        // Return content bentuk json
        // {"message":"Hello from Flutter! update","timestamp":"2025-07-17T14:15:06.583"}
        print('Isi file: $content');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: uploadJsonToFolder,
          child: const Text('Upload JSON ke Google Drive'),
        ),
        SizedBox(height: 30),
        ElevatedButton(onPressed: loadFiles, child: const Text('Load Files')),
        if (uploadStatus != null) Text(uploadStatus!),
      ],
    );
  }
}
