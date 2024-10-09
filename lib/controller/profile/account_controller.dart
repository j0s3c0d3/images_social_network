import 'package:tfg_project/controller/base_controller.dart';
import '../../model/user_model.dart';

class AccountController extends BaseController {

  Future<bool> updateAccount(String email, DateTime birthDate) async {
    String? newEmail = email == userModel.user?.email ? null : email;
    DateTime? newBirthDate = birthDate;
    if (birthDate.year == userModel.user?.birthDate?.year &&
        birthDate.month == userModel.user?.birthDate?.month &&
        birthDate.day == userModel.user?.birthDate?.day) {
      newBirthDate = null;
    }

    User? userResult = await userService.updateAccount(newEmail, newBirthDate);
    bool success = userResult != null;
    if (success) {
      userModel.user = userResult;
      if (newEmail != null) {
        setIsLogged(null);
      }
    }
    return success;
  }

  Future<bool> deleteAccount() async {
    bool success = await userService.deleteAccount(userModel.user!.id!);
    if (success) {
      setIsLogged(null);
    }
    return success;
  }

  Future<bool> checkPassword(String password) async {
    User? user = await userService.loginWithEmailAndPassword(userModel.user!.email!, password, false);
    return user != null;
  }

}