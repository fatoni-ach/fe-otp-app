import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_first_app/controllers/cache_controller.dart';
import 'package:flutter_first_app/models/profile.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OAuthController extends GetxController {
  final clientId = dotenv.env['GC_CLIENT_ID'] ?? '';
  final clientSecret = dotenv.env['GC_CLIENT_SECRET'] ?? '';

  CacheController cacheController = Get.find<CacheController>();

  var profil = Rxn<ProfileGoogle>();
  bool isLoading = true;

  Future<void> fetchUserInfo() async {
    await cacheController.getGoogleAccess();

    var ga = cacheController.googleAccess.value;

    if (ga == null || !ga.isLogin) {
      return;
    }

    // await getProfileGoogle();

    // var profilTemp = profil.value;

    // if (profilTemp?.isLogin ?? false) {
    //   return;
    // }

    final response = await http.get(
      Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
      headers: {'Authorization': 'Bearer ${ga.accessToken}'},
    );

    if (response.statusCode == 200) {
      var temp = ProfileGoogle.fromJson(json.decode(response.body));
      temp.isLogin = true;

      await saveProfileGoogle(temp);

      profil.value = temp;

      isLoading = false;
    }
    if (response.statusCode == 401) {
      var temp = ProfileGoogle(
        sub: '',
        name: '',
        givenName: '',
        familyName: '',
        picture: '',
        email: '',
        emailVerified: false,
        isLogin: false,
      );
      await saveProfileGoogle(temp);
      profil.value = temp;
    } else {
      isLoading = false;
    }
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
}
