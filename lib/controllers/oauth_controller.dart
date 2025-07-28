import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_first_app/controllers/cache_controller.dart';
import 'package:flutter_first_app/models/profile.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OAuthController extends GetxController {
  final clientId = dotenv.env['GC_CLIENT_ID'] ?? '';
  final clientSecret = dotenv.env['GC_CLIENT_SECRET'] ?? '';

  final List<String> scopes = [
    'openid',
    'email',
    'profile',
    'https://www.googleapis.com/auth/drive.file',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'openid',
      'email',
      'profile',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  CacheController cacheController = Get.find<CacheController>();

  var profil = Rxn<ProfileGoogle>();
  bool isLoading = true;

  Future<void> fetchUserInfo() async {
    var account = _googleSignIn.currentUser;

    ProfileGoogle temp;

    if (account == null) {
      temp = ProfileGoogle(
        sub: '',
        name: '',
        givenName: '',
        familyName: '',
        picture: '',
        email: '',
        emailVerified: false,
        isLogin: false,
      );
    } else {
      temp = ProfileGoogle(
        sub: '',
        name: account.displayName.toString(),
        givenName: '',
        familyName: '',
        picture: account.photoUrl.toString(),
        email: account.email.toString(),
        emailVerified: true,
        isLogin: true,
      );
    }

    await saveProfileGoogle(temp);
    profil.value = temp;
  }

  Future<void> saveProfileGoogle(ProfileGoogle profile) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(profile.toJson());
    await prefs.setString('profile_google', jsonString);
  }

  Future<void> getProfileGoogle() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('profile_google') ?? '{}';

    profil.value = ProfileGoogle.fromJson(json.decode(jsonString));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    var profile = ProfileGoogle(
      sub: '',
      name: '',
      givenName: '',
      familyName: '',
      picture: '',
      email: '',
      emailVerified: false,
      isLogin: false,
    );
    final jsonString = jsonEncode(profile.toJson());
    await prefs.setString('profile_google', jsonString);
  }

  Future<void> refreshAccessToken() async {
    await cacheController.getGoogleAccess();

    var ga = cacheController.googleAccess.value;

    if (ga == null) {
      Get.snackbar('Error', 'There is no access');
      return;
    }
    final refreshToken = ga.refreshToken;

    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'refresh_token': refreshToken,
        'grant_type': 'refresh_token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final newAccessToken = jsonData['access_token'];

      await cacheController.saveGoogleAccess(newAccessToken, refreshToken);
    } else {
      Get.snackbar('Error', 'Failed Re login');
    }
  }

  Future<void> login() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;

        var prof = ProfileGoogle(
          sub: '',
          name: account.displayName.toString(),
          givenName: '',
          familyName: '',
          picture: account.photoUrl.toString(),
          email: account.email.toString(),
          emailVerified: true,
          isLogin: true,
        );

        await cacheController.saveGoogleAccess(auth.accessToken.toString(), '');
        await saveProfileGoogle(prof);
        profil.value = prof;
      }
    } catch (e) {
      print('ERROR : ${e.toString()}');
      Get.snackbar('Login Failed', e.toString());
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await cacheController.removeGoogleAccess();
    await logout();
  }
}
