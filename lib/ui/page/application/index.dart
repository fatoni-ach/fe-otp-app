import 'package:flutter/material.dart';
import 'package:flutter_first_app/controllers/application_controller.dart';
import 'package:flutter_first_app/controllers/cache_controller.dart';
import '../../partials/custom_sidebar.dart';
import 'package:get/get.dart';

class ListApplicationPage extends StatefulWidget {
  const ListApplicationPage({super.key});

  @override
  State<ListApplicationPage> createState() => _ListApplicationPageState();
}

class _ListApplicationPageState extends State<ListApplicationPage> {
  final ApplicationController appController = Get.put(ApplicationController());
  final CacheController cacheController = Get.put(CacheController());

  @override
  void initState() {
    cacheController.loadAppList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP APP')),
      drawer: const CustomSidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi saat tombol ditekan
          // Get.snackbar('FAB Pressed', 'Kamu menekan tombol tambah!');
          Get.toNamed('/admin/applications/create');
        },
        child: Icon(Icons.add),
        // tooltip: '',
      ),
      body: Obx(() {
        if (appController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: appController.listApp.length,
          itemBuilder: (context, index) {
            final app = appController.listApp[index];
            return Column(
              children: [
                ListTile(
                  // leading: CircleAvatar(backgroundImage: NetworkImage(a.avatar)),
                  title: Text(app.name),
                  subtitle: Text('ID : ${app.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Konfirmasi'),
                                content: Text(
                                  'Yakin ingin menghapus item ini?',
                                ),
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
                                        await appController.destroy(app.id);
                                        Get.snackbar(
                                          'Success',
                                          'Application Successfully Deleted',
                                        );
                                      } catch (e) {
                                        Get.snackbar(
                                          'error',
                                          'Failed Delete Application',
                                        );
                                      }
                                      Navigator.of(context).pop();
                                      appController.reloadData();
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
                ),
                Divider(),
              ],
            );
          },
        );
      }),
    );
  }
}
