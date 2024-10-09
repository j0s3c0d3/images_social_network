import 'package:tfg_project/controller/base_controller.dart';

import '../../model/user_model.dart';


class FriendsListController extends BaseController {

  Future<List<User>> getFollowers(List<String> followersId) async {
    List<User>? result = await userService.getFollowersProfiles(followersId);
    if (result == null || result == []) {
      userModel.user?.followers = [];
    }
    return result ?? [];
  }

  Future<bool> followOrUnfollow(String userId, bool isFollowing) async {
    return await userService.followOrUnfollow(userModel.user?.id! ?? "", userId, isFollowing);
  }

  String currentUserId() {
    return userModel.user!.id!;
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
}