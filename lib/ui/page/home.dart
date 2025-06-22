// import 'dart:async';
// import 'dart:developer';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_first_app/controllers/application_controller.dart';
import 'package:flutter_first_app/controllers/qr_controller.dart';
import 'package:flutter_first_app/ui/page/qr.dart';
import 'package:permission_handler/permission_handler.dart';
import '../partials/custom_sidebar.dart';
import 'package:get/get.dart';
// import 'package:file_picker/file_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApplicationController appController = Get.put(ApplicationController());
  final QRController controller = Get.put(QRController());

  @override
  void initState() {
    super.initState();
    appController.getPersonalApplication();
  }

  // Future<void> pickImageAndScan() async {
  //   final result = await FilePicker.platform.pickFiles(type: FileType.image);
  //   if (result != null && result.files.single.path != null) {
  //     final file = File(result.files.single.path!);
  //     controller.scanFromFile(file);
  //     Get.snackbar("Qr Code : ", controller.qrResult.value);
  //   }
  // }

  Future<void> pickFromCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      await Get.to(() => QRViewPage());
      // Get.to(() => QRViewPage());
      // if (result != null && result is String) {
      appController
          .reloadPersonalData(); // Bisa juga pakai fetch ulang API, dll.
      // }
    } else {
      Get.snackbar("Izin Dibutuhkan", "Akses kamera ditolak.");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.qrResult.value.isNotEmpty) {
      Get.snackbar("qr code ", controller.qrResult.value);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP APP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              appController.reloadPersonalData();
            },
          ),
        ],
      ),
      drawer: const CustomSidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: pickFromCamera,
        child: Icon(Icons.qr_code_scanner),
      ),

      body: Obx(() {
        if (appController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        int base = appController.currentSecond.value;
        double progress =
            (base < 30) ? base / 30 : (base - 30) / 29; // prevent div by zero
        return RefreshIndicator(
          onRefresh: () async {
            await appController.reloadPersonalData();
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: appController.listApp.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              final app = appController.listApp[index];
              return ListTile(
                // leading: CircleAvatar(backgroundImage: NetworkImage(a.avatar)),
                title: Text(app.name),
                subtitle: Text(
                  app.kodeOtp,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    fontSize: 18,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: Duration(milliseconds: 500),
                      builder: (context, value, _) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                value: value,
                                strokeWidth: 5,
                                backgroundColor: Colors.grey[300],
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        );
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
                                    appController.reloadPersonalData();
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
          ),

          // child: ListView.builder(
          //   itemCount: appController.listApp.length,
          //   itemBuilder: (context, index) {
          //     final app = appController.listApp[index];
          //     return Column(
          //       children: [
          //         ListTile(
          //           // leading: CircleAvatar(backgroundImage: NetworkImage(a.avatar)),
          //           title: Text(app.name),
          //           subtitle: Text(
          //             app.kodeOtp,
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //               color: Colors.blueAccent,
          //               fontSize: 18,
          //             ),
          //           ),
          //           trailing: Row(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               IconButton(
          //                 icon: Icon(Icons.delete, color: Colors.red),
          //                 onPressed: () {
          //                   showDialog(
          //                     context: context,
          //                     builder: (BuildContext context) {
          //                       return AlertDialog(
          //                         title: Text('Konfirmasi'),
          //                         content: Text(
          //                           'Yakin ingin menghapus item ini?',
          //                         ),
          //                         actions: [
          //                           TextButton(
          //                             child: Text('Batal'),
          //                             onPressed: () {
          //                               Navigator.of(
          //                                 context,
          //                               ).pop(); // ⬅️ Menutup dialog
          //                             },
          //                           ),
          //                           ElevatedButton(
          //                             child: Text('Ya'),
          //                             onPressed: () async {
          //                               try {
          //                                 await appController.destroy(app.id);
          //                                 Get.snackbar(
          //                                   'Success',
          //                                   'Application Successfully Deleted',
          //                                 );
          //                               } catch (e) {
          //                                 Get.snackbar(
          //                                   'error',
          //                                   'Failed Delete Application',
          //                                 );
          //                               }
          //                               Navigator.of(context).pop();
          //                               appController.reloadData();
          //                             },
          //                           ),
          //                         ],
          //                       );
          //                     },
          //                   );
          //                 },
          //               ),
          //             ],
          //           ),
          //         ),
          //         Divider(),
          //       ],
          //     );
          //   },
          // ),
        );
        // return;
      }),
    );
  }

  @override
  void dispose() {
    appController.dispose();
    controller.dispose();
    super.dispose();
  }
}
