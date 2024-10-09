import 'package:tfg_project/controller/base_controller.dart';

import '../../model/user_model.dart';

class UpdatePasswordController extends BaseController {

  Future<bool> checkPassword(String password) async {
    User? user = await userService.loginWithEmailAndPassword(userModel.user!.email!, password, false);
    return user != null;
  }

  Future<bool> changePassword(String newPassword) async {
    bool result = await userService.updatePassword(newPassword);
    if (result) {
      userModel.user?.password = newPassword;
      appModel.password = newPassword;
      await storage.write(key: "password", value: newPassword);
    }
    return result;
  }

}