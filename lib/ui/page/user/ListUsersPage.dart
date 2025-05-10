import 'package:flutter/material.dart';
import '../../partials/custom_sidebar.dart';
import 'package:get/get.dart';
import '../../../controllers/user_controller.dart';

class ListUsersPage extends StatelessWidget {
  final UserController userController = Get.put(UserController());
  ListUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP APP')),
      drawer: const CustomSidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/admin/users/create');
        },
        child: Icon(Icons.add),
      ),
      body: Obx(() {
        if (userController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: userController.users.length,
          itemBuilder: (context, index) {
            final user = userController.users[index];
            return ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
              title: Text(user.nama),
              subtitle: Text(user.email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.grey),
                    onPressed: () {
                      Get.toNamed('/admin/users/edit', arguments: user.id);
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
                                    await userController.destroy(user.id);
                                    Get.snackbar(
                                      'Success',
                                      'User Berhasil dihapus',
                                    );
                                  } catch (e) {
                                    Get.snackbar(
                                      'error',
                                      'Gagal menghapus user',
                                    );
                                  }
                                  Navigator.of(context).pop();
                                  userController.reloadData();
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
