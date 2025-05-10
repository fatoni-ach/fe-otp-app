import 'package:flutter/material.dart';
import 'package:flutter_first_app/controllers/user_controller.dart';
import 'package:get/get.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});
  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final UserController controller = Get.find<UserController>();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Create Data')),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
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
                  await controller.store();
                  await controller.reloadData();
                  Get.close(1);
                  Get.snackbar('Sukses', 'User Berhasil ditambahkan');
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Gagal Menambahkan User ${e.toString()}',
                  );
                }
              },
            ),
          ],
        ),
      );
    }),
  );
}
