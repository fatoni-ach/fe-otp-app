import 'package:flutter/material.dart';
import 'package:flutter_first_app/controllers/client_controller.dart';
import 'package:get/get.dart';

class CreateMyKeysPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final ValueNotifier<bool> _activeNotifier = ValueNotifier<bool>(false);
  final ClientController clientController = Get.find<ClientController>();

  CreateMyKeysPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Tambahkan Key')),
    body: Obx(() {
      if (clientController.isLoading.value) {
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
            SizedBox(height: 16),

            ValueListenableBuilder<bool>(
              valueListenable: _activeNotifier,
              builder: (context, value, _) {
                return CheckboxListTile(
                  title: Text('Active'),
                  value: value,
                  onChanged: (newValue) {
                    _activeNotifier.value = newValue ?? false;
                  },
                );
              },
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text;
                bool active = _activeNotifier.value;
                if (name.isNotEmpty) {
                  try {
                    await clientController.store(name, active);
                    Get.back();
                    Get.toNamed('/my/keys', preventDuplicates: true);
                    Get.snackbar('Sukses', 'Data "$name" disimpan');
                    clientController.getMyKeys();
                  } catch (e) {
                    Get.snackbar('Error', 'Failed Store Keys');
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
