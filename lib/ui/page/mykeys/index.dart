import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_first_app/controllers/client_controller.dart';
import '../../partials/custom_sidebar.dart';
import 'package:get/get.dart';

class ListMyKeysPage extends StatefulWidget {
  const ListMyKeysPage({super.key});

  @override
  State<ListMyKeysPage> createState() => _ListMyKeysPageState();
}

class _ListMyKeysPageState extends State<ListMyKeysPage> {
  final ClientController clientController = Get.put(ClientController());

  @override
  void initState() {
    super.initState();
    clientController.getMyKeys();
  }

  @override
  void dispose() {
    super.dispose();
    clientController.dispose();
  }

  void _copyText(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Teks berhasil disalin!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Keys'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              clientController.getMyKeys();
            },
          ),
        ],
      ),
      drawer: CustomSidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/my/keys/create');
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
                    icon: Icon(Icons.copy, color: Colors.grey),
                    onPressed: () => _copyText(context, client.key),
                  ),

                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.grey),
                    onPressed: () {
                      Get.toNamed('/my/keys/edit', arguments: client.id);
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
                                  await clientController.getMyKeys();
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
