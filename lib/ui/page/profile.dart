import 'package:flutter/material.dart';
import '../partials/custom_sidebar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authenticator App')),
      drawer: CustomSidebar(),
      body: const Center(child: Text('Ini Adalah Halaman Profile')),
    );
  }
}
