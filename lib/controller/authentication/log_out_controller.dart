import 'package:tfg_project/controller/base_controller.dart';


class LogOutController extends BaseController {

  Future<bool> logOut() async {
    bool success = await userService.logOut();
    if (success) {
      setIsLogged(null);
    }
    return success;
  }

}