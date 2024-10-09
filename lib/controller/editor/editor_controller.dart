import 'package:http/http.dart' as http;
import 'dart:typed_data';

import 'package:tfg_project/controller/base_controller.dart';
import 'package:tfg_project/model/image_model.dart';
import 'package:tfg_project/util/privacity_enum.dart';


class EditorController extends BaseController {

  Future<bool> uploadImage(ImageWithUser imageWithUser, Privacity privacity) async {
    imageWithUser.image.privacity = privacity;
    ImageWithUser? result = await imageService.uploadImage(imageWithUser);
    return result != null;
  }

  Future<bool> editImage(ImageWithUser imageWithUser, Privacity privacity) async {
    Uint8List? decode = await _imagenUrlAUint8List(imageWithUser.image.image!);
    if (decode == null) {
      return false;
    }
    imageWithUser.image.decode = decode;
    imageWithUser.image.privacity = privacity;
    ImageWithUser? result = await imageService.editImage(imageWithUser);
    return result != null;
  }

  Future<bool> deleteImage(ImageWithUser imageWithUser) async {
    return await imageService.deleteImage(imageWithUser);
  }

  ImageWithUser createImageWithUser(String? description, Uint8List image) {
    Image modelImage = Image(decode: image, userId: userModel.user!.id!, description: description, creationDate: DateTime.now(), privacity: Privacity.all);
    return ImageWithUser(image: modelImage, user: userModel.user!);
  }

  Future<Uint8List?> _imagenUrlAUint8List(String urlImagen) async {
    final respuesta = await http.get(Uri.parse(urlImagen));
    if (respuesta.statusCode == 200) {
      return Uint8List.fromList(respuesta.bodyBytes);
    } else {
      return null;
    }
  }

}