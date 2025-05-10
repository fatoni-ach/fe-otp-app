import 'package:flutter/material.dart';
import 'package:flutter_first_app/controllers/user_controller.dart';
import 'package:get/get.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final UserController controller = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    final userId = Get.arguments as int;
    controller.detail(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Pengguna')),
      body: Obx(() {
        final user = controller.user.value;
        if (user == null) {
          return Center(child: Text('User tidak ditemukan'));
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ID:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${user.id}'),
              SizedBox(height: 16),
              Text("Nama:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(user.nama),
              SizedBox(height: 16),

              Text("Email:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(user.email),
              SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }
}
