import 'package:flutter_first_app/models/Application.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_controller.dart';

class CacheController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  var listApp = <Application>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> saveUserList(List<Application> apps) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = encodeAppllicationList(apps);
    await prefs.setString('application_list', jsonString);
  }

  Future<void> loadUserList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('application_list');
    if (jsonString != null) {
      final apps = decodeUserList(jsonString);

      listApp.value = apps;
    }
  }

  void addUser(String name, issuer, secret) async {
    final newUser = Application(
      id: 0,
      name: name,
      issuer: issuer,
      secret: secret,
      kodeOtp: "",
    );
    final temp = listApp.value;

    if (temp == null) {
      return;
    }

    final newList = [...temp, newUser];

    listApp.value = newList;
    await saveUserList(newList);
    await loadUserList();
  }
}
