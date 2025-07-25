import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_first_app/controllers/application_controller.dart';
import 'package:flutter_first_app/controllers/cache_controller.dart';
import 'package:flutter_first_app/controllers/gd_controller.dart';
import 'package:flutter_first_app/controllers/oauth_controller.dart';
import 'package:flutter_first_app/models/Application.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class BackupV2Page extends StatefulWidget {
  const BackupV2Page({super.key});

  @override
  State<BackupV2Page> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupV2Page> {
  OAuthController oAuthController = Get.find<OAuthController>();
  GdController gdController = Get.find<GdController>();
  CacheController cacheController = Get.find<CacheController>();
  ApplicationController applicationController =
      Get.find<ApplicationController>();

  final clientId = dotenv.env['GC_CLIENT_ID'];
  final clientSecret = dotenv.env['GC_CLIENT_SECRET'];
  final redirectUri = dotenv.env['GC_REDIRECT_URI'];
  final scopes =
      'openid email profile https://www.googleapis.com/auth/drive.file';

  @override
  void initState() {
    oAuthController.fetchUserInfo();
    super.initState();
  }

  @override
  void dispose() {
    oAuthController.dispose();
    gdController.dispose();
    cacheController.dispose();
    super.dispose();
  }

  Future<void> _connectToDrive() async {
    await oAuthController.fetchUserInfo();

    var profil = oAuthController.profil.value;

    if (profil == null || !profil.isLogin) {
      await oAuthController.refreshAccessToken();
      await oAuthController.fetchUserInfo();
      profil = oAuthController.profil.value;

      if (profil == null || !profil.isLogin) {
        await oAuthController.logout();
        final state = DateTime.now().millisecondsSinceEpoch.toString();
        final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
          'response_type': 'code',
          'client_id': clientId,
          'redirect_uri': redirectUri,
          'scope': scopes,
          'state': state,
          'access_type': 'offline',
          'prompt': 'consent',
        });

        // Buka browser default
        launchUrl(authUrl);
      }
    }
  }

  Future<void> _backupData() async {
    await gdController.uploadOrReplaceInFolder();
  }

  Future<void> _restoreData() async {
    final files = await gdController.listDriveFiles();
    for (var file in files) {
      if (file['name'] == 'backup.bak') {
        final content = await gdController.downloadFileContent(file['id']);

        var contentString = jsonDecode(content ?? '[]');

        var listApp = decodeApplicationList(contentString);

        await cacheController.loadAppList;

        var cacheAppList = cacheController.listApp.value;

        listApp.addAll(cacheAppList);

        await cacheController.saveAppList(listApp);
        Get.snackbar('Sukses', 'Data berhasil di restore');
        break;
      }
    }
  }

  Future<void> _disconnect() async {
    await oAuthController.logout();
    await cacheController.saveGoogleAccess('', '');
    await oAuthController.getProfileGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), actions: [
        ],
      ),
      // drawer: CustomSidebar(),
      body: Obx(() {
        var profil = oAuthController.profil.value;

        if (profil == null || !profil.isLogin) {
          return Center(
            child: Column(
              children: [
                Image.asset('assets/google_drive.png', height: 80),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _connectToDrive,
                  child: const Text('Connect to drive'),
                ),
                const SizedBox(width: 20),
              ],
            ),
          );
        }

        // print("PROFIL : ${profil.name}");
        return Center(
          child: Column(
            children: [
              Image.asset('assets/google_drive.png', height: 80),
              const SizedBox(height: 10),
              Text(profil.email),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _backupData,
                child: const Text('Backup ke Drive'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _restoreData,
                child: const Text('Restore dari Drive'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _disconnect,
                child: const Text('Disconnect'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      }),
    );
  }
}
