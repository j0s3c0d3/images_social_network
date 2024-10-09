import 'package:firebase_storage/firebase_storage.dart';
import 'package:tfg_project/services/user_service.dart';
import 'package:tfg_project/util/privacity_enum.dart';
import '../model/image_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/user_model.dart';
import 'notification_service.dart';


class ImageService {

  final _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UserService userService = UserService();
  final NotificationService notificationService = NotificationService();


  Future<ImageWithUser?> uploadImage(ImageWithUser imageWithUser) async {
    try {
      Reference reference = _storage.ref().child(imageWithUser.user.id!).child(imageWithUser.image.creationDate!.microsecondsSinceEpoch.toString());
      UploadTask uploadTask = reference.putData(imageWithUser.image.decode!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      imageWithUser.image.image = imageUrl;

      bool success = false;
      await _db.collection("imagenes").add(imageWithUser.image.toFirestore()).whenComplete(() => success = true);
      return success ? imageWithUser : null;
    }
    catch (e) {
      return null;
    }
  }


  Future<ImageWithUser?> editImage(ImageWithUser imageWithUser) async {
    try {
      await _storage.refFromURL(imageWithUser.image.image!).delete();

      Reference reference = _storage.ref().child(imageWithUser.user.id!).child(imageWithUser.image.creationDate!.microsecondsSinceEpoch.toString());
      UploadTask uploadTask = reference.putData(imageWithUser.image.decode!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      bool success = false;
      await _db.collection("imagenes").where("image", isEqualTo: imageWithUser.image.image!).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          imageWithUser.image.image = imageUrl;
          querySnapshot.docs.first.reference.set(
            imageWithUser.image.toFirestore(),
            SetOptions(merge: false),
          );
          success = true;
        }
      });
      return success ? imageWithUser : null;
    }
    catch (e) {
      return null;
    }
  }


  Future<bool> deleteImage(ImageWithUser imageWithUser) async {
    try {
      await _storage.refFromURL(imageWithUser.image.image!).delete();

      bool success = false;
      await _db.collection("imagenes").where("image", isEqualTo: imageWithUser.image.image!).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.first.reference.delete();
          success = true;
        }
      });
      return success;
    }
    catch (e) {
      return false;
    }
  }




  Future<List<Image>?> getUserImages(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _db.collection("imagenes").where("userId", isEqualTo: userId).get();
      if (querySnapshot.docs.isNotEmpty) {
        List<DocumentSnapshot> imagesSnapshot = querySnapshot.docs;

        List<Image> images = imagesSnapshot.map((doc) {
          return Image.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
        }).toList();

        return images;
      }
      return [];
    } catch (e) {
      return null;
    }
  }


  Future<ImageWithUser?> getImageWithUser(String imageId) async {
    try {
      QuerySnapshot querySnapshot = await _db.collection("imagenes").where("image", isEqualTo: imageId).get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot imageSnapshot = querySnapshot.docs.first;
        Image image = Image.fromFirestore(imageSnapshot as DocumentSnapshot<Map<String, dynamic>>);
        User? user = await userService.getUserData(image.userId!);
        if (user != null) {
          return ImageWithUser(image: image, user: user);
        }
      }
    }
    catch (e) {}
    return null;
  }


  Future<List<ImageWithUser>?> getFeedImagesWithUser(String userId, int likes) async {
    try {
      List<User>? followedUsers = await userService.getFollowedUsers(userId, null);
      List<ImageWithUser> result = [];
      for (User user in followedUsers!) {
        QuerySnapshot querySnapshot = await _db.collection("imagenes").where("userId", isEqualTo: user.id).get();
        if (querySnapshot.docs.isNotEmpty) {
          List<DocumentSnapshot> imagesSnapshot = querySnapshot.docs;
          List<Image> images = imagesSnapshot.map((doc) {
            return Image.fromFirestore(
                doc as DocumentSnapshot<Map<String, dynamic>>);
          }).toList();

          for (Image image in images) {
            if (image.privacity != Privacity.none && (image.likes?.length ?? 0) >= likes) {
              ImageWithUser imageWithUser = ImageWithUser(user: user, image: image);
              result.add(imageWithUser);
            }
          }
        }
      }
      result.sort((a, b) => b.image.creationDate!.compareTo(a.image.creationDate!));
      return result;
    }
    catch (e) {
      return null;
    }
  }

  Future<List<ImageWithUser>?> getAllImagesWithUser(String userId, int likes) async {
    try {
      List<ImageWithUser> result = [];

      QuerySnapshot querySnapshot = await _db.collection("imagenes").get();
      if (querySnapshot.docs.isNotEmpty) {
        List<DocumentSnapshot> imagesSnapshot = querySnapshot.docs;
        List<Image> images = imagesSnapshot.map((doc) {
          return Image.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>);
        }).toList();

        for (Image image in images) {
          if ((image.likes?.length ?? 0) >= likes) {
            User? user = await userService.getUserData(image.userId!);
            ImageWithUser imageWithUser = ImageWithUser(user: user!, image: image);
            result.add(imageWithUser);
          }
        }
      }

      result.sort((a, b) => b.image.creationDate!.compareTo(a.image.creationDate!));
      return result;
    }
    catch (e) {
      return null;
    }
  }

  Future<bool> likeOrDislikeImage(String userId, String image, bool isLiked) async {
    try {
      await _db.collection("imagenes").where("image", isEqualTo: image).get().then((querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot imageSnapshot = querySnapshot.docs.first;
          Image imageModel = Image.fromFirestore(imageSnapshot as DocumentSnapshot<Map<String, dynamic>>);
          if (isLiked) {
            if (userId != imageModel.userId!) {
              bool success = await notificationService.removeNotification(userId, imageModel.userId!, image);
              if (!success) return false;
            }
            imageSnapshot.reference.update({
              'likes': FieldValue.arrayRemove([userId]),
            });
          }
          else {
            if (userId != imageModel.userId!) {
              bool success = await notificationService.addNotification(imageModel.userId!, userId, image);
              if (!success) return false;
            }
            imageSnapshot.reference.update({
              'likes': FieldValue.arrayUnion([userId]),
            });
          }
        }
      });
      return true;
    }
    catch (e) {
      return false;
    }
  }
}