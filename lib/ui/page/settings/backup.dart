import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_first_app/controllers/cache_controller.dart';
import 'package:flutter_first_app/controllers/gd_controller.dart';
import 'package:flutter_first_app/controllers/oauth_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  OAuthController oAuthController = Get.find<OAuthController>();
  GdController gdController = Get.find<GdController>();
  CacheController cacheController = Get.find<CacheController>();

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
    super.dispose();
  }

  Future<void> _connectToDrive() async {
    await oAuthController.fetchUserInfo();

    var profil = oAuthController.profil.value;

    if (profil == null || !profil.isLogin) {
      await oAuthController.refreshAccessToken();
      await oAuthController.fetchUserInfo();
      profil = oAuthController.profil.value;

      print("PROFIL : ${profil?.isLogin}");
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

        print("PROFIL : ${profil.name}");
        return Center(
          child: Column(
            children: [
              Image.asset('assets/google_drive.png', height: 80),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _backupData,
                child: const Text('Backup ke Drive'),
              ),
              const SizedBox(width: 20),
            ],
          ),
        );
      }),
    );
  }
}
