import 'package:tfg_project/controller/base_controller.dart';

import '../../model/user_model.dart';

class LoginController extends BaseController {

  Future<bool> login(String email, String password) async {
    User? user = await userService.loginWithEmailAndPassword(email, password, false);
    setIsLogged(user);
    return user != null;
  }

}