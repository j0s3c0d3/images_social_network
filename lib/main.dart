import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:tfg_project/services/image_service.dart';
import 'package:tfg_project/services/notification_service.dart';
import 'package:tfg_project/view/editor/editor.dart';
import 'firebase_options.dart';

import 'package:tfg_project/model/app_model.dart';
import 'package:tfg_project/model/user_model.dart';
import 'package:tfg_project/services/user_service.dart';
import 'package:tfg_project/view/authentication/login.dart';
import 'package:tfg_project/view/home.dart';

import 'controller/base_controller.dart' as controllers;


class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (c) => AppModel()),
          ChangeNotifierProvider(create: (c) => UserModel()),
          Provider(create: (c) => UserService()),
          Provider(create: (c) => ImageService()),
          Provider(create: (c) => NotificationService())
        ],
        child: Builder(builder: (context) {
          controllers.init(context);
          return MaterialApp(
              theme: ThemeData(
                platform: TargetPlatform.android,
                appBarTheme: const AppBarTheme(
                    color: Colors.deepOrange,
                    elevation: 10,
                    toolbarHeight: 60,
                    titleTextStyle: TextStyle(fontSize: 25, color: Colors.black)
                ),
                inputDecorationTheme: const InputDecorationTheme(
                  isDense: true,
                  filled: true,
                  errorStyle: TextStyle(
                      fontStyle: FontStyle.italic
                  ),
                ),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.white,
                    showSelectedLabels: false,
                    selectedIconTheme: IconThemeData(
                        color: Colors.black,
                        size: 40
                    ),
                    unselectedIconTheme: IconThemeData(
                        color: Colors.deepOrange,
                        size: 30
                    ),
                ),
                colorSchemeSeed: Colors.deepOrange,
                useMaterial3: true,
              ),
              routes: {
                '/login': (context) => const LoginPage(),
                '/home': (context) => const Home(),
                '/editor': (context) => const EditorPage(),
              },
              initialRoute: '/',
              home: const App()
          );
        }),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  final controller = controllers.BaseController();

  late Future<bool?> isLogged;

  Future<bool?> future() async {
    await Future.delayed(const Duration(seconds: 3));
    return controller.getIsLogged();
  }

  @override
  void initState() {
    isLogged = future();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: isLogged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const LoginPage();
          } else if (snapshot.hasData) {
            if (snapshot.data == false) {
              return const LoginPage();
            }
            else {
              return const Home();
            }
          } else {
            return const LoginPage();
          }
        } else {
          return Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: const Center(child: CircularProgressIndicator(color: Colors.deepOrange),),
          );
        }
      },
    );
  }
}

