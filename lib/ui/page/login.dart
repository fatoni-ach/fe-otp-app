import 'package:flutter/material.dart';
import 'home.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    // Inisialisasi AuthController
    final AuthController authController = Get.find<AuthController>();

    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            authController.isLoggedIn.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: () async {
                    try {
                      await authController.login(
                        usernameController.text,
                        passwordController.text,
                      );
                      Get.offAll(() => const HomePage());
                    } catch (e) {
                      Get.snackbar(
                        'Login Error',
                        'Username atau Password salah',
                      );
                    }
                  },
                  child: const Text('Login'),
                ),
          ],
        ),
      ),
    );
  }
}
