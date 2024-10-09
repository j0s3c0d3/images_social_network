
import 'package:tfg_project/controller/base_controller.dart';
import 'package:tfg_project/util/privacity_enum.dart';

import '../../model/image_model.dart' as model;


class FeedController extends BaseController {

  Future<List<model.ImageWithUser>?> getFeedImages(int likes) async {
    return imageService.getFeedImagesWithUser(userModel.user!.id!, likes);
  }

  Future<List<model.ImageWithUser>?> getAllImages(int likes) async {
    List<model.ImageWithUser>? result = await imageService.getAllImagesWithUser(userModel.user!.id!, likes);
    List<model.ImageWithUser>? filteredResult = [];

    if (result != null && result.isNotEmpty) {
      for (model.ImageWithUser image in result) {
        if (image.image.userId == userModel.user!.id ||
            image.image.privacity == Privacity.all ||
            (image.image.privacity == Privacity.friends && (image.user.followers ?? []).contains(userModel.user!.id))) {
          filteredResult.add(image);
        }
      }
    }
    return filteredResult;
  }

  bool checkIsLiked(model.Image image) {
    for (String id in image.likes ?? []) {
      if (id == userModel.user!.id) return true;
    }
    return false;
  }

  bool checkIsOwner(String userId) {
    return userId == userModel.user!.id;
  }

  Future<bool?> likeOrDislikeImage(model.Image image, bool isLiked) async {
    return await imageService.likeOrDislikeImage(userModel.user!.id!, image.image!, isLiked);
  }
}