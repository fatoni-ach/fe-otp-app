import 'package:flutter/material.dart';
import 'package:flutter_first_app/ui/page/home.dart';
// import '../page/login.dart';
import '../../controllers/auth_controller.dart';
import 'package:get/get.dart';

class CustomSidebar extends StatelessWidget {
  CustomSidebar({super.key});
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
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
          (authController.isLoggedIn.value) ? _isLoggin() : _isNotLogin(),
        ],
      ),
    );
  }

  Widget _isLoggin() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.key),
          title: const Text('My Keys'),
          onTap: () {
            Get.back();
            Get.toNamed("/my/keys");
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () async {
            await authController.logout(); // Logout
            Get.offAll(HomePage());
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
    );
  }

  // http://localhost:8000/#/auth?state=1752246200012&code=4/0AVMBsJhyBZnKOGC4m8F0uaStj7KynmFO8mnLgmmes4t68LoMV6NvSRMkofTCykcqJOheQQ&scope=https://www.googleapis.com/auth/drive.file
  Widget _isNotLogin() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.login),
          title: const Text('Login'),
          onTap: () {
            Get.toNamed("/login");
          },
        ),
        ListTile(
          leading: const Icon(Icons.login),
          title: const Text('Login With Google'),
          onTap: () {
            Get.toNamed("/oauth/login");
          },
        ),
        ListTile(
          leading: const Icon(Icons.upload),
          title: const Text('Upload File'),
          onTap: () {
            Get.toNamed("/upload-json");
          },
        ),
      ],
    );
  }
}
