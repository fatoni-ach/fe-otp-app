import 'package:flutter/material.dart';
import '../page/login.dart';
import '../../controllers/auth_controller.dart';
import 'package:get/get.dart';

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 100,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Authenticator App',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            title: const Text('My Account'),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Get.back();
              Get.toNamed("/");
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await authController.logout(); // Logout
              Get.offAll(LoginPage());
            },
          ),

          const Divider(color: Colors.transparent, height: 20),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            title: const Text('Master Data'),
          ),
          const Divider(height: 0),

          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Daftar User'),
            onTap: () {
              Get.back();
              Get.toNamed("/admin/users");
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Daftar Aplikasi'),
            onTap: () {
              Get.back();
              Get.toNamed("/admin/applications");
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Daftar Client'),
            onTap: () {
              Get.back();
              Get.toNamed("/admin/clients");
            },
          ),
        ],
      ),
    );
  }
}
