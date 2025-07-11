import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TokenCapturePage extends StatefulWidget {
  @override
  _TokenCapturePageState createState() => _TokenCapturePageState();
}

class _TokenCapturePageState extends State<TokenCapturePage> {
  String? accessToken;

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
    final state = Get.parameters['state'];

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

    print('Access Token: $accessToken');
    print('Refresh Token: $refreshToken');

    this.accessToken = accessToken;
    setState(() {});
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
