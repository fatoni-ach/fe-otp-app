import 'package:flutter/material.dart';
import 'package:flutter_first_app/controllers/user_controller.dart';
import 'package:get/get.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({super.key});
  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final UserController controller = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    final userId = Get.arguments as int;
    controller.detail(userId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Edit Data')),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final user = controller.user.value;

      if (user == null) {
        return Center(child: Text('User tidak ditemukan'));
      }

      controller.nameController.text = user.nama;
      controller.emailController.text = user.email;
      controller.passwordController.text = '';
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Simpan'),
              onPressed: () async {
                try {
                  await controller.edit(user.id);
                  await controller.reloadData();
                  Get.close(1);
                  Get.snackbar('Sukses', 'User Berhasil di edit');
                } catch (e) {
                  Get.snackbar('Error', 'Gagal Mengedit User ${e.toString()}');
                }
              },
            ),
          ],
        ),
      );
    }),
  );
}
