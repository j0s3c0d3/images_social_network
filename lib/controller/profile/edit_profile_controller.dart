import 'dart:typed_data';

import 'package:tfg_project/controller/base_controller.dart';

import '../../model/user_model.dart';


class EditProfileController extends BaseController {

  Future<bool> editProfile(String userName, Uint8List? profileImage) async {
    String? newUserName = userName == userModel.user?.userName ? null : userName;
    User? userResult = await userService.editProfile(newUserName, profileImage);
    bool success = userResult != null;
    if (success) {
      userModel.user = userResult;
    }
    return success;
  }

}