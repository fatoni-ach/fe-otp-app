import 'dart:html' as html;
import 'package:flutter/material.dart';

const clientId = 'blabla.apps.googleusercontent.com';
const redirectUri = 'http://localhost:55326'; // atau yang terdaftar
const scopes = 'https://www.googleapis.com/auth/drive.file';

class GoogleDriveWebAuth extends StatelessWidget {
  void authorizeWithGoogleDrive() {
    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'response_type': 'token',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scopes,
      'include_granted_scopes': 'true',
      'state': 'drive_auth',
    });

    html.window.location.href = authUrl.toString(); // pindah ke Google Login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Drive Auth Web")),
      body: Center(
        child: ElevatedButton(
          onPressed: authorizeWithGoogleDrive,
          child: Text("Authorize Google Drive"),
        ),
      ),
    );
  }
}
