import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SettingsV2Page extends StatefulWidget {
  const SettingsV2Page({super.key});

  @override
  State<SettingsV2Page> createState() => _SettingState();
}

class _SettingState extends State<SettingsV2Page> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh),
        //     onPressed: () {
        //       // clientController.getListClient();
        //     },
        //   ),
        // ],
      ),
      // drawer: CustomSidebar(),
      body: Column(
        children: [
          // ElevatedButton(onPressed: null, child: Text('Backup data')),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup data'),
            onTap: () {
              // Get.back();
              // Get.toNamed("/my/keys");
              Get.toNamed('v2/settings/backup');
            },
          ),
        ],
      ),
    );
  }
}
