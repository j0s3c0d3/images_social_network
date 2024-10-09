import 'package:tfg_project/controller/base_controller.dart';
import 'package:tfg_project/model/notification_model.dart';

import '../../model/user_model.dart';
import '../../model/image_model.dart';


class ProfileController extends BaseController {

  Future<User?> getUserProfile(String? userId) async {
    if (userId != null) {
      return userService.getUserData(userId);
    }
    else {
      User? user = await userService.getUserData(userModel.user!.id!);
      if (user != null) {
        userModel.user = user;
      }
      return user;
    }
  }

  User getOwnUser() {
    return userModel.user!;
  }

  Future<List<Image>?> getUserImages(String? userId) async {
    List<Image>? userImages;

    if (userId != null) {
      userImages = await imageService.getUserImages(userId);
    } else {
      userImages = await imageService.getUserImages(userModel.user!.id!);
    }

    userImages?.sort((a, b) => (b.creationDate ?? DateTime.now()).compareTo(a.creationDate ?? DateTime.now()));
    return userImages;
  }

  bool checkFriendship(List<String> followers) {
    bool result = false;
    for (String follower in followers) {
      if (follower == userModel.user?.id) {
        result = true;
        break;
      }
    }
    return result;
  }

  Future<bool> followOrUnfollow(String userId, bool isFollowing) async {
    return await userService.followOrUnfollow(userModel.user?.id! ?? "", userId, isFollowing);
  }

  Future<List<UserNotification>> getUserNotifications(String userId) async {
    List<UserNotification>? result = await notificationService.getUserNotifications(userId);
    return result ?? [];
  }

  Future<bool> deactivateNotification(String notificationId) async {
    return await notificationService.deactivateNotification(notificationId);
  }
}