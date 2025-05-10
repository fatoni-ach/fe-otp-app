import 'package:flutter/material.dart';
import 'package:flutter_first_app/ui/page/application/index.dart';
import 'package:flutter_first_app/ui/page/user/ListUsersPage.dart';
import '../page/profile.dart';
import '../page/home.dart';
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
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'OTP App',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Tutup Drawer dulu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.person),
          //   title: const Text('Profile'),
          //   onTap: () {
          //     Navigator.pop(context); // Tutup Drawer dulu
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const ProfilePage()),
          //     );
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.settings),
          //   title: const Text('Settings'),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context); // Tutup Drawer dulu

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false, // Ini penting: hapus semua halaman sebelumnya
              );
              await authController.logout(); // Logout
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Daftar User'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListUsersPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Daftar Aplikasi'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListApplicationPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
