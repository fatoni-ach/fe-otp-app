import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_first_app/controllers/auth_controller.dart';
import 'package:flutter_first_app/models/client.dart';
import 'package:flutter_first_app/ui/page/login.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClientController extends GetxController {
  var listClient = <Client>[].obs;
  // var listMyKey = <Client>[].obs;
  var client = Rxn<Client>();
  var isLoading = true.obs;
  var otpBaseUri = dotenv.env['API_OTP_BASE_URI'] ?? 'http://localhost';
  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> getListClient() async {
    try {
      isLoading(true);
      var response = await http.get(
        Uri.parse('$otpBaseUri/v1/clients?limit=100'),
        headers: {'Authorization': 'Bearer ${authController.token.value}'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var listAppData = data['data']['rows'] as List;
        listClient.value = listAppData.map((e) => Client.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        authController.logout();
        Get.offAll(LoginPage());
      } else {
        Get.snackbar('Error', 'Failed to load applications');
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> getMyKeys() async {
    try {
      isLoading(true);
      var response = await http.get(
        Uri.parse('$otpBaseUri/v1/my/keys?limit=100'),
        headers: {'Authorization': 'Bearer ${authController.token.value}'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var listMyKeyTemp = data['data']['rows'] as List;
        listClient.value =
            listMyKeyTemp.map((e) => Client.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        authController.logout();
        Get.offAll(LoginPage());
      } else {
        Get.snackbar('Error', 'Failed to load applications');
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> store(String name, bool active) async {
    try {
      isLoading(true);
      var response = await http.post(
        Uri.parse('$otpBaseUri/v1/clients'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.token.value}',
        },
        body: json.encode({'name': name, 'active': active}),
      );
      if (response.statusCode != 200) {
        Get.snackbar('Error', 'Failed store client');
        return;
      }
      getListClient();
    } finally {
      isLoading(false);
    }
  }

  Future<void> edit(int id, String name, bool active) async {
    try {
      isLoading(true);
      var response = await http.put(
        Uri.parse('$otpBaseUri/v1/clients/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.token.value}',
        },
        body: json.encode({'name': name, 'active': active}),
      );
      if (response.statusCode != 200) {
        Get.snackbar('Error', 'Failed update client');
        return;
      }
      getListClient();
    } finally {
      isLoading(false);
    }
  }

  Future<void> editMyKeys(int id, String name, bool active) async {
    try {
      isLoading(true);
      var response = await http.put(
        Uri.parse('$otpBaseUri/v1/my/keys/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.token.value}',
        },
        body: json.encode({'name': name, 'active': active}),
      );
      if (response.statusCode != 200) {
        Get.snackbar('Error', 'Failed update client');
        return;
      }
      getMyKeys();
    } finally {
      isLoading(false);
    }
  }

  void detail(int id) async {
    final url = Uri.parse('$otpBaseUri/v1/clients/$id');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authController.token.value}',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          client.value = Client.fromJson(data['data']);
          return;
        } else {
          throw Exception('Status Code not 200');
        }
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal Get client : $e');
    }
  }

  void detailMyKeys(int id) async {
    final url = Uri.parse('$otpBaseUri/v1/my/keys/$id');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authController.token.value}',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          client.value = Client.fromJson(data['data']);
          return;
        } else {
          throw Exception('Status Code not 200');
        }
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal Get client : $e');
    }
  }

  Future<void> destroy(int id) async {
    try {
      isLoading(true);
      var response = await http.delete(
        Uri.parse('$otpBaseUri/v1/clients/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.token.value}',
        },
      );
      if (response.statusCode != 200) {
        Get.snackbar('Error', 'Failed to load applications');
      }
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    // timer.cancel();
    super.onClose();
  }
}
