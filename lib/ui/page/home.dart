import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_first_app/controllers/application_controller.dart';
import 'package:flutter_first_app/controllers/cache_controller.dart';
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
  final CacheController cacheController = Get.put(CacheController());

  final QRController qrController = Get.put(QRController());

  @override
  void initState() {
    super.initState();
    // appController.getPersonalApplication();
    cacheController.loadAppList();
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
      cacheController.loadAppList(); // Bisa juga pakai fetch ulang API, dll.
      // }
    } else {
      Get.snackbar("Izin Dibutuhkan", "Akses kamera ditolak.");
    }
  }

  void _copyText(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Teks berhasil disalin!')));
  }

  @override
  Widget build(BuildContext context) {
    if (qrController.qrResult.value.isNotEmpty) {
      Get.snackbar("qr code ", qrController.qrResult.value);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              cacheController.loadAppList();
            },
          ),
        ],
      ),
      drawer: CustomSidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: pickFromCamera,
        child: Icon(Icons.qr_code_scanner),
      ),

      body: Obx(() {
        // if (appController.isLoading.value) {
        //   return const Center(child: CircularProgressIndicator());
        // }
        int base = cacheController.currentSecond.value;
        double progress =
            (base < 30) ? base / 30 : (base - 30) / 29; // prevent div by zero
        return RefreshIndicator(
          onRefresh: () async {
            await cacheController.loadAppList();
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: cacheController.listApp.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              final app = cacheController.listApp[index];
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
                    IconButton(
                      icon: Icon(Icons.copy, color: Colors.grey),
                      onPressed: () => _copyText(context, app.kodeOtp),
                    ),
                    SizedBox(width: 10),
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
                                backgroundColor: Colors.blue,
                                color: Colors.grey[300],
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
                                      await cacheController.removeAppByIndex(
                                        index,
                                      );
                                      await cacheController.loadAppList();
                                      // await appController.destroy(app.id);
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
                                    // appController.reloadPersonalData();
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
        );
        // return;
      }),
    );
  }

  @override
  void dispose() {
    appController.dispose();
    qrController.dispose();
    cacheController.dispose();
    super.dispose();
  }
}
