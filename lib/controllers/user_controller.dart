import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_first_app/models/user.dart';
import 'auth_controller.dart';

class UserController extends GetxController {
  var users = <User>[].obs;
  var user = Rxn<User>();
  var isLoading = true.obs;
  var otpBaseUri = dotenv.env['API_OTP_BASE_URI'] ?? 'http://localhost';

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

  void fetchUsers() async {
    try {
      isLoading(true);

      var response = await http.get(
        Uri.parse('$otpBaseUri/v1/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.token.value}',
        },
      );
      // print(response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var usersData = data['data']['rows'] as List;
        users.value = usersData.map((e) => User.fromJson(e)).toList();
      } else {
        Get.snackbar('Error', 'Failed to load users');
      }
    } finally {
      isLoading(false);
    }
  }

  void detail(int id) async {
    final url = Uri.parse('$otpBaseUri/v1/users/$id');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authController.token.value}',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          user.value = User.fromJson(data['data']);
          return;
        } else {
          throw Exception('Status Code not 200');
        }
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal delete user : $e');
    }
  }

  Future<void> reloadData() async {
    fetchUsers();
  }

  Future<void> destroy(int id) async {
    final url = Uri.parse('$otpBaseUri/v1/users/$id');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authController.token.value}',
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          return;
        } else {
          throw Exception('Status Code not 200');
        }
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal delete user : $e');
    }
  }

  Future<void> store() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar("Validasi", "Semua field wajib diisi");
      return;
    }

    final url = Uri.parse('$otpBaseUri/v1/users');

    var body = {'name': name, 'email': email, 'password': password};
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authController.token.value}',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          return;
        } else {
          throw Exception('Login gagal');
        }
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Login gagal: $e');
    }
  }

  Future<void> edit(int id) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty) {
      Get.snackbar("Validasi", "Semua field wajib diisi");
      return;
    }

    final url = Uri.parse('$otpBaseUri/v1/users/$id');

    var body = {
      'name': name,
      'email': email,
      'password': password,
      'is_update_password': (password == '') ? false : true,
    };
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authController.token.value}',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          return;
        } else {
          throw Exception('Login gagal');
        }
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Login gagal: $e');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
