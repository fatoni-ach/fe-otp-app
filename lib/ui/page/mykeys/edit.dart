import 'package:flutter/material.dart';
import 'package:flutter_first_app/controllers/client_controller.dart';
import 'package:get/get.dart';

class EditMyKeysPage extends StatefulWidget {
  const EditMyKeysPage({super.key});
  @override
  State<EditMyKeysPage> createState() => _EditMyKeysPageState();
}

class _EditMyKeysPageState extends State<EditMyKeysPage> {
  final ClientController controller = Get.find<ClientController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController keyController = TextEditingController();
  final ValueNotifier<bool> activeNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    final clientId = Get.arguments as int;
    controller.detail(clientId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Update My Keys')),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final client = controller.client.value;

      if (client == null) {
        return Center(child: Text('Client tidak ditemukan'));
      }

      nameController.text = client.name;
      activeNotifier.value = client.active;
      keyController.text = client.key;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              enabled: false,
              controller: keyController,
              decoration: InputDecoration(
                labelText: 'Key',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            ValueListenableBuilder<bool>(
              valueListenable: activeNotifier,
              builder: (context, value, _) {
                return CheckboxListTile(
                  title: Text('Active'),
                  value: value,
                  onChanged: (newValue) {
                    activeNotifier.value = newValue ?? false;
                  },
                );
              },
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Simpan'),
              onPressed: () async {
                try {
                  await controller.edit(
                    client.id,
                    nameController.text,
                    activeNotifier.value,
                  );
                  Get.back();
                  Get.snackbar('Sukses', 'Client Berhasil di edit');
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Gagal Mengedit CLient ${e.toString()}',
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
