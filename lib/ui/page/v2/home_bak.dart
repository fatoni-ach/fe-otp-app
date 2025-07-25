import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_first_app/controllers/application_controller.dart';
import 'package:flutter_first_app/controllers/auth_controller.dart';
import 'package:flutter_first_app/controllers/auth_local_controller.dart';
import 'package:flutter_first_app/controllers/cache_controller.dart';
import 'package:flutter_first_app/controllers/oauth_controller.dart';
import 'package:flutter_first_app/controllers/qr_controller.dart';
import 'package:flutter_first_app/ui/page/qr.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeV2Page extends StatefulWidget {
  const HomeV2Page({super.key});

  @override
  State<HomeV2Page> createState() => _HomePageV2State();
}

class _HomePageV2State extends State<HomeV2Page> {
  final ApplicationController appController = Get.find<ApplicationController>();
  final AuthController authController = Get.find<AuthController>();
  final CacheController cacheController = Get.find<CacheController>();
  final OAuthController oAuthController = Get.find<OAuthController>();
  final authLocalController = Get.find<AuthLocalController>();

  final QRController qrController = Get.find<QRController>();

  @override
  void initState() {
    super.initState();
    cacheController.loadAppList();
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: pickFromCamera,
        ),
        title: const Text('', style: TextStyle(color: Colors.black)),
        actions: [
          Icon(Iconsax.search_normal_1_copy, color: Colors.black),
          SizedBox(width: 16),
          // Icon(Icons.settings, color: Colors.black),
          // SizedBox(width: 16),
          IconButton(
            icon: Icon(Iconsax.setting_2_copy, color: Colors.black),
            onPressed: () {
              Get.toNamed('/v2/settings');
            },
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        int base = cacheController.currentSecond.value;
        double progress = (base < 30) ? base / 30 : (base - 30) / 29;

        return RefreshIndicator(
          onRefresh: () async {
            await cacheController.loadAppList();
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: cacheController.listApp.length,
            // separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              final app = cacheController.listApp[index];

              return otpTile(
                index: index,
                title: "${app.name}",
                subtitle: "${app.issuer}",
                code: app.kodeOtp,
                icon: Icons.videogame_asset,
                seconds: 30 - (base.toInt() % 30),
                progress: progress,
              );
            },
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    appController.dispose();
    qrController.dispose();
    cacheController.dispose();
    authController.dispose();
    super.dispose();
  }

  Widget otpTile({
    required int index,
    required String title,
    String? subtitle,
    required String code,
    required IconData icon,
    required double seconds,
    required double progress,
    bool showRefresh = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                code,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Iconsax.copy_copy, color: Colors.grey),
                    onPressed: () => _copyText(context, code),
                  ),
                  const SizedBox(width: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: Duration(milliseconds: 500),
                    builder: (context, value, _) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 2,
                              backgroundColor: Colors.grey.shade400,
                              color: Colors.grey.shade200,
                              semanticsLabel: 'test',
                              semanticsValue: 'test',
                            ),
                          ),
                          Text(
                            seconds
                                .toString(), // atau ganti dengan countdown detik misalnya
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Iconsax.trash_copy, color: Colors.red),
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
            ],
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }
}
