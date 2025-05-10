import 'package:flutter/material.dart';
import 'package:flutter_first_app/controllers/application_controller.dart';
import 'package:get/get.dart';

class CreateApplicationPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final ApplicationController applicationController =
      Get.find<ApplicationController>();

  CreateApplicationPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Create Data')),
    body: Obx(() {
      if (applicationController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text;
                if (name.isNotEmpty) {
                  try {
                    await applicationController.store(name);
                    Get.back();
                    Get.toNamed('/admin/applications', preventDuplicates: true);
                    Get.snackbar('Sukses', 'Data "$name" disimpan');
                    await applicationController.reloadData();
                  } catch (e) {
                    Get.snackbar('Error', 'Failed Store Application');
                  }
                } else {
                  Get.snackbar('Error', 'Nama tidak boleh kosong');
                }
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      );
    }),
  );
}
