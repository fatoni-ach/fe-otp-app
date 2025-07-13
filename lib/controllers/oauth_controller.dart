import 'dart:async';

import 'package:flutter_first_app/controllers/cache_controller.dart';
import 'package:flutter_first_app/models/profile.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OAuthController extends GetxController {
  CacheController cacheController = Get.find<CacheController>();
  // Map<String, dynamic>? userInfo;
  var profil = Rxn<ProfileGoogle>();
  bool isLoading = true;

  Future<void> fetchUserInfo() async {
    await cacheController.getGoogleAccess();

    var ga = cacheController.googleAccess.value;

    if (ga == null || !ga.isLogin) {
      return;
    }

    await getProfileGoogle();

    var profilTemp = profil.value;

    if (profilTemp == null || profilTemp.isLogin) {
      return;
    }

    final response = await http.get(
      Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
      headers: {'Authorization': 'Bearer ${ga.accessToken}'},
    );

    if (response.statusCode == 200) {
      // var userInfo = json.decode(response.body);
      var temp = ProfileGoogle.fromJson(json.decode(response.body));
      temp.isLogin = true;

      await saveProfileGoogle(temp);

      profil.value = temp;

      // print('USER INFO : ${response.body}');
      isLoading = false;
    } else {
      isLoading = false;
      // print('Failed to fetch user info: ${response.body}');
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
}
