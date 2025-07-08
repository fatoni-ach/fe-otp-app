import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleDriveAuthDesktop extends StatelessWidget {
  var clientId = 'blabla.apps.googleusercontent.com';
  var clientSecret = 'blabla';
  var redirectUri = 'com.authenticator-app:/auth';
  var scopes = 'https://www.googleapis.com/auth/drive.file';
  Future<void> authorizeWithGoogleDrive() async {
    final authUrl =
        'https://accounts.google.com/o/oauth2/v2/auth?response_type=code'
        '&client_id=$clientId'
        '&redirect_uri=$redirectUri'
        '&scope=$scopes'
        '&access_type=offline'
        '&prompt=consent';

    // 1. Buka browser login Google
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: 'com.authenticator-app',
    );

    // 2. Ambil code dari URL callback
    final code = Uri.parse(result).queryParameters['code'];

    // 3. Tukar code dengan access token
    final response = await http.post(
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

    final tokenData = jsonDecode(response.body);
    final accessToken = tokenData['access_token'];
    final refreshToken = tokenData['refresh_token'];

    print("Access Token: $accessToken");
    print("Refresh Token: $refreshToken");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Drive Auth - Desktop")),
      body: Center(
        child: ElevatedButton(
          onPressed: authorizeWithGoogleDrive,
          child: Text("Authorize Google Drive"),
        ),
      ),
    );
  }
}
