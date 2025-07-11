import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_first_app/ui/partials/custom_sidebar.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleOAuthPage extends StatelessWidget {
  GoogleOAuthPage({super.key});

  final clientId = dotenv.env['GC_CLIENT_ID'];
  final clientSecret = dotenv.env['GC_CLIENT_SECRET'];
  final redirectUri = dotenv.env['GC_REDIRECT_URI'];
  final scopes = 'https://www.googleapis.com/auth/drive.file';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google OAuth Desktop')),
      drawer: CustomSidebar(),
      body: Center(
        child: ElevatedButton(
          onPressed: _authenticate,
          child: const Text('Login with Google'),
        ),
      ),
    );
  }
}
