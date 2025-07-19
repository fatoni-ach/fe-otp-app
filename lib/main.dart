import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_first_app/controllers/application_controller.dart';
import 'package:flutter_first_app/controllers/cache_controller.dart';
import 'package:flutter_first_app/controllers/gd_controller.dart';
import 'package:flutter_first_app/controllers/oauth_controller.dart';
import 'package:flutter_first_app/controllers/qr_controller.dart';
import 'package:flutter_first_app/middleware/auth_middleware.dart';
// import 'package:flutter_first_app/models/user.dart';
import 'package:flutter_first_app/ui/page/application/create.dart';
import 'package:flutter_first_app/ui/page/application/index.dart';
import 'package:flutter_first_app/ui/page/auth/token_capture.dart';
import 'package:flutter_first_app/ui/page/client/ListClientPage.dart';
import 'package:flutter_first_app/ui/page/client/create.dart';
import 'package:flutter_first_app/ui/page/client/edit.dart';
import 'package:flutter_first_app/ui/page/auth/google_oauth.dart';
import 'package:flutter_first_app/ui/page/mykeys/create.dart';
import 'package:flutter_first_app/ui/page/mykeys/edit.dart';
import 'package:flutter_first_app/ui/page/mykeys/index.dart';
import 'package:flutter_first_app/ui/page/settings/backup.dart';
import 'package:flutter_first_app/ui/page/settings/settings.dart';
import 'package:flutter_first_app/ui/page/upload_json.dart';
import 'package:flutter_first_app/ui/page/user/ListUsersPage.dart';
import 'package:flutter_first_app/ui/page/user/create.dart';
import 'package:flutter_first_app/ui/page/user/detail.dart';
import 'package:flutter_first_app/ui/page/user/edit.dart';
import 'package:get/get.dart';
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
    // return MaterialApp(
    //   title: 'Authenticator App',
    //   theme: ThemeData(
    //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    //   ),
    //   home: const MyHomePage(title: 'Authenticator App'),
    // );

    return MyHomePage(title: 'Authenticator App');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AuthController authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Authenticator App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // home: HomePage(),
      // home: Obx(() {
      //   // Cek status login dan arahkan ke halaman yang sesuai
      //   if (authController.isLoggedIn.value) {
      //     return const HomePage();
      //   } else {
      //     return const LoginPage();
      //   }
      // }), // ⬅️ Awal masuk ke LoginPage dulu
      initialBinding: BindingsBuilder(() {
        Get.put(ApplicationController());
        Get.put(CacheController());
        Get.put(OAuthController());
        Get.put(QRController());
        Get.put(GdController());
      }),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => HomePage(),
          // middlewares: [AuthMiddleware()],
        ),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/oauth/login', page: () => GoogleOAuthPage()),
        GetPage(name: '/oauth/callback', page: () => TokenCapturePage()),
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
        GetPage(
          name: '/admin/clients',
          page: () => ListClientPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/admin/clients/create',
          page: () => CreateClientPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/admin/clients/edit',
          page: () => EditClientPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/my/keys',
          page: () => ListMyKeysPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/my/keys/create',
          page: () => CreateMyKeysPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/my/keys/edit',
          page: () => EditMyKeysPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/upload-json',
          page: () => UploadJsonToDrive(),
          // middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/settings',
          page: () => SettingsPage(),
          // middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/settings/backup',
          page: () => BackupPage(),
          // middlewares: [AuthMiddleware()],
        ),
      ],
    );
  }
}
