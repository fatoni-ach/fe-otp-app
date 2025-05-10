import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_first_app/ui/page/home.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var token = ''.obs;
  var otpBaseUri = dotenv.env['API_OTP_BASE_URI'] ?? 'http://localhost';

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  // Cek status login dari SharedPreferences
  _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString('auth_token') ?? '';
    if (token.value.isNotEmpty) {
      isLoggedIn.value = true;
    }
  }

  // Login dan simpan token
  Future<void> login(String username, String password) async {
    // Simulate API login request
    // Ganti dengan request API nyata (kirim ke API)tprint('USERNAME : '+ username)
    // print('BASE_URI : ' + otpBaseUri);
    final url = Uri.parse('$otpBaseUri/v1/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': username, 'password': password}),
      );

      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          final tokenData = data['data']['token'] ?? '';
          // Simpan token ke SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'auth_token',
            tokenData,
          ); // Token yang diterima dari API

          // Update status login di GetX
          token.value = tokenData;
          isLoggedIn.value = true;

          // Navigasi ke HomePage
          // Get.offAll(() => const HomePage()); // Pindah ke HomePage
        } else {
          // Get.snackbar('Error', 'Login Gagal');
          throw Exception('Login gagal');
        }
      } else {
        // Get.snackbar('Error', 'Server Error');

        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      // Get.snackbar('Error', 'Login Gagal');

      throw Exception('Login gagal: $e');
    }
  }

  // Logout dan hapus token
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    token.value = '';
    isLoggedIn.value = false;
  }
}
