import 'package:tfg_project/controller/base_controller.dart';

import '../../model/image_model.dart';

class NotificationsListController extends BaseController {

  Future<ImageWithUser?> getImageWithUser(String imageId) async {
    return await imageService.getImageWithUser(imageId);
  }

}