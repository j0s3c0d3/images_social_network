import 'dart:typed_data';

import 'package:tfg_project/controller/base_controller.dart';

import '../../model/user_model.dart';

class SignUpController extends BaseController {

  Future<bool> signUp(String email, String password, String userName, Uint8List? profileImage, DateTime birthDate) async {
    User user = User(userName: userName, password: password, email: email, profileImageFile: profileImage, birthDate: birthDate, followers: []);
    User? userResult = await userService.signUp(user);
    setIsLogged(userResult);
    return userResult != null;
  }

}