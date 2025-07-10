import 'dart:html' as html;
import 'package:flutter/material.dart';

class TokenCapturePage extends StatefulWidget {
  @override
  _TokenCapturePageState createState() => _TokenCapturePageState();
}

class _TokenCapturePageState extends State<TokenCapturePage> {
  String? accessToken;

  @override
  void initState() {
    super.initState();
    // Ambil token dari URL fragment
    final fragment = html.window.location.hash; // "#access_token=..."
    final params = Uri.splitQueryString(fragment.replaceFirst('#', ''));

    if (params.containsKey('access_token')) {
      accessToken = params['access_token'];
      print("Access Token: $accessToken");
    }
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
