import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_first_app/controllers/oauth_controller.dart';
import 'package:flutter_first_app/ui/partials/custom_sidebar.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleOAuthPage extends StatefulWidget {
  const GoogleOAuthPage({super.key});

  @override
  State<GoogleOAuthPage> createState() => _GoogleOAuthPageState();
}

class _GoogleOAuthPageState extends State<GoogleOAuthPage> {
  // final cacheController = Get.find<CacheController>();
  final oAuthController = Get.find<OAuthController>();

  final clientId = dotenv.env['GC_CLIENT_ID'];
  final clientSecret = dotenv.env['GC_CLIENT_SECRET'];
  final redirectUri = dotenv.env['GC_REDIRECT_URI'];
  final scopes =
      'openid email profile https://www.googleapis.com/auth/drive.file';

  Future<void> _authenticate() async {
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

  // Future<void> _refreshToken() async {
  //   await oAuthController.refreshAccessToken();
  // }

  Future<void> _logout() async {
    await oAuthController.logout();
    await oAuthController.getProfileGoogle();
  }

  @override
  void initState() {
    oAuthController.fetchUserInfo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google OAuth Desktop')),
      drawer: CustomSidebar(),
      body: Obx(() {
        var profil = oAuthController.profil.value;
        // bool isLogin = false;

        // if (profil != null && profil.isLogin) {
        //   isLogin = profil.isLogin;
        // }

        if (profil == null) {
          return Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _authenticate,
                  child: const Text('Login with Google'),
                ),
              ],
            ),
          );
        }

        return (profil.isLogin)
            ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  // CircleAvatar(
                  //   backgroundImage: NetworkImage(
                  //     'https://placehold.jp/150x150.png',
                  //   ),
                  //   radius: 40,
                  // ),
                  const SizedBox(height: 10),
                  Text('Name: ${profil.name}'),
                  Text('Email: ${profil.email}'),
                  // Text('Email: ${profile.picture}'),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _logout,
                    child: const Text('Logout'),
                  ),
                ],
              ),
            )
            : Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _authenticate,
                    child: const Text('Login with Google'),
                  ),
                ],
              ),
            );
      }),
    );
  }
}
