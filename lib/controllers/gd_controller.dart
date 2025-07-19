import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_first_app/controllers/cache_controller.dart';
import 'package:flutter_first_app/models/Application.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class GdController extends GetxController {
  CacheController cacheController = Get.find<CacheController>();
  String _accessToken = '';
  final fileName = 'backup.bak';

  @override
  void onInit() async {
    // TODO: implement onInit
    await cacheController.getGoogleAccess();

    var ga = cacheController.googleAccess.value;

    super.onInit();
    if (ga == null) {
      return;
    }

    _accessToken = ga.accessToken;
  }

  Future<bool> uploadFile(
    Uint8List fileBytes,
    String fileName,
    String folderId,
  ) async {
    final uri = Uri.parse(
      'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart',
    );
    final boundary = 'flutter_boundary';

    final metadata = {
      'name': fileName,
      'mimeType': 'application/json',
      'parents': [folderId],
    };

    final body = <int>[];
    body.addAll(utf8.encode('--$boundary\r\n'));
    body.addAll(
      utf8.encode('Content-Type: application/json; charset=UTF-8\r\n\r\n'),
    );
    body.addAll(utf8.encode(json.encode(metadata)));
    body.addAll(utf8.encode('\r\n'));

    body.addAll(utf8.encode('--$boundary\r\n'));
    body.addAll(utf8.encode('Content-Type: application/json\r\n\r\n'));
    body.addAll(fileBytes);
    body.addAll(utf8.encode('\r\n--$boundary--\r\n'));

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'multipart/related; boundary=$boundary',
      },
      body: Uint8List.fromList(body),
    );

    // print('Upload status: ${response.statusCode}');
    return response.statusCode == 200;
  }

  Future<String?> getOrCreateFolder(String folderName) async {
    // Step 1: Check if folder exists
    final query =
        "mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false";
    final listUri = Uri.parse(
      'https://www.googleapis.com/drive/v3/files?q=${Uri.encodeComponent(query)}&fields=files(id,name)',
    );
    final listResponse = await http.get(
      listUri,
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (listResponse.statusCode == 200) {
      final data = json.decode(listResponse.body);
      final files = data['files'] as List<dynamic>;
      if (files.isNotEmpty) {
        return files.first['id'];
      }
    }

    // Step 2: Create folder if not exists
    final createUri = Uri.parse('https://www.googleapis.com/drive/v3/files');
    final createResponse = await http.post(
      createUri,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': folderName,
        'mimeType': 'application/vnd.google-apps.folder',
      }),
    );

    if (createResponse.statusCode == 200) {
      final created = json.decode(createResponse.body);
      return created['id'];
    } else {
      // print('Gagal membuat folder: ${createResponse.body}');
      Get.snackbar('Failed', 'Error backup data (create folder)');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> listDriveFiles() async {
    final uri = Uri.parse(
      'https://www.googleapis.com/drive/v3/files?q=mimeType="application/json"&fields=files(id,name,mimeType)',
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List files = data['files'];
      return files.cast<Map<String, dynamic>>();
    } else {
      print('Gagal mengambil daftar file: ${response.body}');
      return [];
    }
  }

  Future<String?> downloadFileContent(String fileId) async {
    final uri = Uri.parse(
      'https://www.googleapis.com/drive/v3/files/$fileId?alt=media',
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      return utf8.decode(response.bodyBytes); // isi file dalam bentuk string
    } else {
      print('Gagal download file: ${response.body}');
      return null;
    }
  }

  Future<void> uploadOrReplaceInFolder() async {
    var folderId = await getOrCreateFolder('authenticator');

    await cacheController.loadAppList();

    var listApp = cacheController.listApp.value;

    var jsonData = encodeAppllicationList(listApp);

    final contentJson = json.encode(jsonData);
    final contentBytes = utf8.encode(contentJson);

    // Step 1: Cek apakah file dengan nama tersebut sudah ada di folder
    final query =
        "name='$fileName' and '${folderId}' in parents and trashed=false";
    final uri = Uri.parse(
      'https://www.googleapis.com/drive/v3/files?q=${Uri.encodeComponent(query)}&fields=files(id,name)',
    );

    final searchResponse = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    String? fileIdToReplace;

    if (searchResponse.statusCode == 200) {
      final data = json.decode(searchResponse.body);
      final files = data['files'] as List<dynamic>;
      if (files.isNotEmpty) {
        fileIdToReplace = files.first['id'];
      }
    }

    if (fileIdToReplace != null) {
      // File sudah ada → replace isinya via PATCH
      final patchUri = Uri.parse(
        'https://www.googleapis.com/upload/drive/v3/files/$fileIdToReplace?uploadType=media',
      );

      final patchResponse = await http.patch(
        patchUri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: Uint8List.fromList(contentBytes),
      );

      if (patchResponse.statusCode == 200) {
        Get.snackbar('Success', 'Berhasil backup data');
      } else {
        Get.snackbar('Failed', 'Gagal backup data');
      }
    } else {
      // File tidak ada → Upload baru ke folder
      final uploadUri = Uri.parse(
        'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart',
      );
      final boundary = 'flutter_form_boundary';

      final metadata = {
        'name': fileName,
        'mimeType': 'application/json',
        'parents': [folderId],
      };

      final body = <int>[];
      body.addAll(utf8.encode('--$boundary\r\n'));
      body.addAll(
        utf8.encode('Content-Type: application/json; charset=UTF-8\r\n\r\n'),
      );
      body.addAll(utf8.encode(json.encode(metadata)));
      body.addAll(utf8.encode('\r\n'));

      body.addAll(utf8.encode('--$boundary\r\n'));
      body.addAll(utf8.encode('Content-Type: application/json\r\n\r\n'));
      body.addAll(contentBytes);
      body.addAll(utf8.encode('\r\n--$boundary--\r\n'));

      final postResponse = await http.post(
        uploadUri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'multipart/related; boundary=$boundary',
        },
        body: Uint8List.fromList(body),
      );

      if (postResponse.statusCode == 200) {
        Get.snackbar('Success', 'Berhasil backup data');
      } else {
        Get.snackbar('Failed', 'Gagal backup data');
      }
    }
  }
}
