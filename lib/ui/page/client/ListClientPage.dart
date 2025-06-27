import 'package:flutter/material.dart';
import 'package:flutter_first_app/controllers/client_controller.dart';
import '../../partials/custom_sidebar.dart';
import 'package:get/get.dart';

class ListClientPage extends StatefulWidget {
  const ListClientPage({super.key});

  @override
  State<ListClientPage> createState() => _ListClientPageState();
}

class _ListClientPageState extends State<ListClientPage> {
  final ClientController clientController = Get.put(ClientController());

  @override
  void initState() {
    super.initState();
    clientController.getListClient();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Client')),
      drawer: const CustomSidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/admin/clients/create');
        },
        child: Icon(Icons.add),
      ),
      body: Obx(() {
        if (clientController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: clientController.listClient.length,
          itemBuilder: (context, index) {
            final client = clientController.listClient[index];
            return ListTile(
              // leading: CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
              title: Text(
                client.name + ((client.active) ? " | ACTIVE" : " | NONAKTIF"),
              ),
              subtitle: Text(client.key),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.grey),
                    onPressed: () {
                      Get.toNamed('/admin/clients/edit', arguments: client.id);
                    },
                  ),

                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Konfirmasi'),
                            content: Text('Yakin ingin menghapus item ini?'),
                            actions: [
                              TextButton(
                                child: Text('Batal'),
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pop(); // ⬅️ Menutup dialog
                                },
                              ),
                              ElevatedButton(
                                child: Text('Ya'),
                                onPressed: () async {
                                  try {
                                    await clientController.destroy(client.id);
                                    Get.snackbar(
                                      'Success',
                                      'Client Berhasil dihapus',
                                    );
                                  } catch (e) {
                                    Get.snackbar(
                                      'error',
                                      'Gagal menghapus Client',
                                    );
                                  }
                                  Navigator.of(context).pop();
                                  await clientController.getListClient();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
