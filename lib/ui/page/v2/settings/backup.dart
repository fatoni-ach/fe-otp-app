import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_first_app/controllers/application_controller.dart';
import 'package:flutter_first_app/controllers/cache_controller.dart';
import 'package:flutter_first_app/controllers/gd_controller.dart';
import 'package:flutter_first_app/controllers/oauth_controller.dart';
import 'package:flutter_first_app/models/Application.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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
    await oAuthController.login();
    // await oAuthController.fetchUserInfo();

    // var profil = oAuthController.profil.value;

    // if (profil == null || !profil.isLogin) {
    //   await oAuthController.refreshAccessToken();
    //   await oAuthController.fetchUserInfo();
    //   profil = oAuthController.profil.value;

    //   if (profil == null || !profil.isLogin) {
    //     await oAuthController.logout();
    //     final state = DateTime.now().millisecondsSinceEpoch.toString();
    //     final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
    //       'response_type': 'code',
    //       'client_id': clientId,
    //       'redirect_uri': redirectUri,
    //       'scope': scopes,
    //       'state': state,
    //       'access_type': 'offline',
    //       'prompt': 'consent',
    //     });

    //     // Buka browser default
    //     launchUrl(authUrl);
    //   }
    // }
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
        await cacheController.loadAppList();
        Get.snackbar('Sukses', 'Data berhasil di restore');
        break;
      }
    }
  }

  Future<void> _disconnect() async {
    await oAuthController.signOut();
    await oAuthController.fetchUserInfo();
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
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _connectToDrive,
                  icon: Icon(
                    Icons.keyboard_double_arrow_up_rounded,
                  ), // Ganti dengan ikon sesuai kebutuhan
                  label: Text('Connect to drive'), // Label teks
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: Column(
            children: [
              Image.asset('assets/google_drive.png', height: 80),
              const SizedBox(height: 5),
              Text(
                profil.email,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _backupData,
                icon: Icon(
                  Icons.backup_outlined,
                ), // Ganti dengan ikon sesuai kebutuhan
                label: Text('Backup ke Drive'), // Label teks
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _restoreData,
                icon: Icon(
                  Icons.restore_outlined,
                ), // Ganti dengan ikon sesuai kebutuhan
                label: Text('Restore dari Drive'), // Label teks
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _disconnect,
                icon: Icon(
                  Iconsax.logout_copy,
                ), // Ganti dengan ikon sesuai kebutuhan
                label: Text('Disconnect'), // Label teks
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
