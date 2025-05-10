import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_first_app/middleware/auth_middleware.dart';
import 'package:flutter_first_app/models/user.dart';
import 'package:flutter_first_app/ui/page/application/create.dart';
import 'package:flutter_first_app/ui/page/application/index.dart';
import 'package:flutter_first_app/ui/page/user/ListUsersPage.dart';
import 'package:flutter_first_app/ui/page/user/create.dart';
import 'package:flutter_first_app/ui/page/user/detail.dart';
import 'package:flutter_first_app/ui/page/user/edit.dart';
import 'controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_first_app/ui/partials/custom_sidebar.dart';
import 'ui/page/home.dart';
import 'ui/page/profile.dart';
import 'ui/page/login.dart';
import 'controllers/auth_controller.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTP App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Otp App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    return GetMaterialApp(
      title: 'OTP App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Obx(() {
        // Cek status login dan arahkan ke halaman yang sesuai
        if (authController.isLoggedIn.value) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      }), // ⬅️ Awal masuk ke LoginPage dulu
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => HomePage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/profile', page: () => ProfilePage()),
        GetPage(
          name: '/admin/users',
          page: () => ListUsersPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/admin/users/create',
          page: () => CreateUserPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/admin/users/detail',
          page: () => UserDetailPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/admin/users/edit',
          page: () => EditUserPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/admin/applications',
          page: () => ListApplicationPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/admin/applications/create',
          page: () => CreateApplicationPage(),
          middlewares: [AuthMiddleware()],
        ),
      ],
    );
  }
}
