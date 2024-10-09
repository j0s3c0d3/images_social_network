import '../../model/user_model.dart';
import '../base_controller.dart';

class ExploreController extends BaseController {

  Future<List<User>?> getFollowedUsers(String? username) async {
    return await userService.getFollowedUsers(userModel.user!.id!, username);
  }

  Future<List<User>?> getAllUsers(String username) async {
    return await userService.getAllUsers(username);
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

  String currentUserId() {
    return userModel.user!.id!;
  }

  Future<bool> followOrUnfollow(String userId, bool isFollowing) async {
    return await userService.followOrUnfollow(userModel.user?.id! ?? "", userId, isFollowing);
  }
}