import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tfg_project/repository/example_repository.dart';

import '../model/app_model.dart';
import '../model/user_model.dart';
import '../repository/notification_repository.dart';
import '../repository/user_repository.dart';
import 'package:tfg_project/repository/image_repository.dart';

BuildContext? _mainContext;
void init(BuildContext c) => _mainContext = c;

class BaseController {

  UserModel get userModel => _mainContext?.read() ?? UserModel();
  AppModel get appModel => _mainContext?.read() ?? AppModel();

  UserRepository get userService => _mainContext?.read() ?? UserRepository();
  ImageRepository get imageService => _mainContext?.read() ?? ImageRepository();
  NotificationRepository get notificationService => _mainContext?.read() ?? NotificationRepository();
  ExampleRepository get exampleService => _mainContext?.read() ?? ExampleRepository();

  final Future<SharedPreferences> sharedPrefs = SharedPreferences.getInstance();
  final storage = const FlutterSecureStorage();


  Future<bool> getIsLogged() async {
    SharedPreferences prefs = await sharedPrefs;
    appModel.isLogged = prefs.getBool("isLogged") ?? false;

    if (appModel.isLogged == true) {
      String? email = await storage.read(key: "email");
      String? password = await storage.read(key: "password");
      appModel.email = email;
      appModel.password = password;

      User? user = await userService.loginWithEmailAndPassword(email ?? "", password ?? "", true);
      userModel.user = user;
      if (user == null) {
        appModel.isLogged = false;
        if (email != null) {
          appModel.email = null;
          appModel.password = null;
          await storage.delete(key: "password");
          await storage.delete(key: "email");
        }
      }
    }

    return appModel.isLogged!;
  }

  void setIsLogged(User? user) async {
    bool isLogged = user != null;
    SharedPreferences prefs = await sharedPrefs;

    userModel.user = user;
    appModel.isLogged = isLogged;
    prefs.setBool("isLogged", isLogged);

    if (isLogged) {
      appModel.password = user.password;
      await storage.write(key: "password", value: user.password!);
      appModel.email = user.email;
      await storage.write(key: "email", value: user.email!);
    } else {
      appModel.password = null;
      await storage.delete(key: "password");
      appModel.email = null;
      await storage.delete(key: "email");
    }
  }
}