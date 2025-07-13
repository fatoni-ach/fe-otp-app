import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_first_app/controllers/cache_controller.dart';
import 'package:flutter_first_app/controllers/oauth_controller.dart';
import 'package:flutter_first_app/ui/page/home.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TokenCapturePage extends StatefulWidget {
  const TokenCapturePage({super.key});

  @override
  State<TokenCapturePage> createState() => _TokenCapturePageState();
}

class _TokenCapturePageState extends State<TokenCapturePage> {
  String? accessToken;

  final cacheController = Get.find<CacheController>();
  final oAuthController = Get.find<OAuthController>();

  final clientId = dotenv.env['GC_CLIENT_ID'];
  final clientSecret = dotenv.env['GC_CLIENT_SECRET'];
  final redirectUri = dotenv.env['GC_REDIRECT_URI'];

  @override
  void initState() {
    getCode();
    super.initState();
  }

  Future<void> getCode() async {
    final code = Get.parameters['code'];
    // final state = Get.parameters['state'];

    final tokenResponse = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'code': code,
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
      },
    );

    final tokenData = jsonDecode(tokenResponse.body);
    final accessToken = tokenData['access_token'];
    final refreshToken = tokenData['refresh_token'];

    await cacheController.saveGoogleAccess(accessToken, refreshToken);
    await oAuthController.fetchUserInfo();

    Get.snackbar('Success', 'You success login to OAUTH');
    Get.offAll(HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Token Callback")),
      body: Center(
        child: Text(
          accessToken != null
              ? "Access Token:\n$accessToken"
              : "Tidak ada token ditemukan",
        ),
      ),
    );
  }
}
