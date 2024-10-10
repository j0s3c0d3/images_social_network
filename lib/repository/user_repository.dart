import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart' as FireAuth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tfg_project/repository/notification_repository.dart';
import '../model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserRepository {

  final FireAuth.FirebaseAuth _auth = FireAuth.FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final NotificationRepository notificationService = NotificationRepository();

  Future<User?> loginWithEmailAndPassword(String email, String password, bool isInitial) async {
    if (isInitial) {
      if (_auth.currentUser == null || _auth.currentUser!.email != email) {
        return null;
      }
    }

    try {
      QuerySnapshot querySnapshot = await _db.collection("usuarios").where("email", isEqualTo: email).get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = querySnapshot.docs.first;
        User user = User.fromFirestore(userSnapshot as DocumentSnapshot<Map<String, dynamic>>);
        FireAuth.UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
        if (credential.user != null && credential.user!.uid == user.id!) {
          user.password = password;
          return user;
        }
      }
      return null;
    }
    catch (e) {
      return null;
    }
  }


  Future<User?> signUp(User user) async {
    try {
      FireAuth.UserCredential credential = await _auth.createUserWithEmailAndPassword(email: user.email!, password: user.password!);
      if (credential.user != null) {
        FireAuth.User authUser = credential.user!;
        user.id = authUser.uid;
        if (user.profileImageFile != null) {
          user.profileImage = await _setProfileImage(user.profileImageFile!, user.id!);
        }

        bool success = false;
        await _db.collection("usuarios").add(user.toFirestore()).whenComplete(() => success = true);
        return success ? user : null;
      }
      return null;
    }
    catch (e) {
      return null;
    }
  }


  Future<String> _setProfileImage(Uint8List image, String user) async {
    Reference reference = _storage.ref().child("profileImage").child(user);
    UploadTask uploadTask = reference.putData(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> _deleteProfileImage(String userId) async {
    Reference reference = _storage.ref().child("profileImage").child(userId);
    await reference.delete();
  }

  Future<User?> editProfile(String? userName, Uint8List? profileImage) async {
    try {
      final currentUser = _auth.currentUser;
      final userId = currentUser!.uid;

      final Map<String, dynamic> updatedData = {};
      bool deleteImage = false;
      if (userName != null) {
        updatedData['userName'] = userName;
      }
      if (profileImage != null) {
        if (profileImage.isEmpty) {
          deleteImage = true;
          await _deleteProfileImage(userId);
        }
        else {
          String imageUrl = await _setProfileImage(profileImage, userId);
          updatedData['profileImage'] = imageUrl;
        }
      }

      await _db.collection("usuarios").where("id", isEqualTo: userId).get().then((querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;
          if (updatedData.isNotEmpty) {
            await userDoc.reference.update(updatedData);
          }
          if (deleteImage) {
            await userDoc.reference.update({"profileImage": FieldValue.delete()});
          }
        }
      });

      final updatedUserData = await getUserData(userId);
      return updatedUserData;
    } catch (e) {
      return null;
    }
  }

  Future<User?> updateAccount(String? email, DateTime? birthDate) async {
    try {
      final currentUser = _auth.currentUser;
      final userId = currentUser!.uid;
      final Map<String, dynamic> updatedData = {};

      if (email != null) {
        currentUser.verifyBeforeUpdateEmail(email);
        updatedData['email'] = email;
      }

      if (birthDate != null) {
        updatedData['birthDate'] = birthDate;
      }

      if (updatedData.isNotEmpty) {
        await _db.collection("usuarios").where("id", isEqualTo: userId).get().then((querySnapshot) async {
          if (querySnapshot.docs.isNotEmpty) {
            final userDoc = querySnapshot.docs.first;
            await userDoc.reference.update(updatedData);
          }
        });
      }

      final updatedUserData = await getUserData(userId);
      return updatedUserData;
    }
    catch (e) {
      return null;
    }
  }

  Future<bool> deleteAccount(String userId) async {
    try {
      await _db.collection("usuarios").where("id", isEqualTo: userId).get().then((querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;
          await userDoc.reference.delete();
        }
        else {
          return false;
        }
      });
      await _auth.currentUser?.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePassword(String password) async {
    try {
      final currentUser = _auth.currentUser;
      currentUser!.updatePassword(password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logOut() async {
    try {
      await _auth.signOut();
      return true;
    }
    catch (e) {
      return false;
    }
  }


  Future<User?> getUserData(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _db.collection("usuarios").where("id", isEqualTo: userId).get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = querySnapshot.docs.first;
        User user = User.fromFirestore(userSnapshot as DocumentSnapshot<Map<String, dynamic>>);
        return user;
      }
      return null;
    }
    catch (e) {
      return null;
    }
  }


  Future<List<User>?> getFollowersProfiles(List<String> followers) async {
    try {
      List<User> followersList = [];
      for (String followerId in followers) {
        QuerySnapshot querySnapshot = await _db.collection("usuarios").where("id", isEqualTo: followerId).get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = querySnapshot.docs.first;
          User follower = User.fromFirestore(userSnapshot as DocumentSnapshot<Map<String, dynamic>>);
          followersList.add(follower);
        }
      }
      return followersList;
    }
    catch (e) {
      return null;
    }
  }


  Future<bool> followOrUnfollow(String currentUserId, String userId, bool isFollowing) async {
    try {
      await _db.collection('usuarios').where("id", isEqualTo: userId).get().then((querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          if (isFollowing) {
            bool success = await notificationService.removeNotification(currentUserId, userId, null);
            if (!success) return false;
            querySnapshot.docs.first.reference.update({
              'followers': FieldValue.arrayRemove([currentUserId]),
            });
          }
          else {
            bool success = await notificationService.addNotification(userId, currentUserId, null);
            if (!success) return false;
            querySnapshot.docs.first.reference.update({
              'followers': FieldValue.arrayUnion([currentUserId]),
            });
          }
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<User>?> getFollowedUsers(String userId, String? username) async {
    try {
      QuerySnapshot querySnapshot = await _db.collection("usuarios").where("followers", arrayContains: userId).get();
      List<User> users = [];
      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot doc in querySnapshot.docs) {
          User user = User.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
          if (username == null || user.userName.toLowerCase().contains(username.toLowerCase())) {
            users.add(user);
          }
        }
        users.sort((a, b) => a.userName.toLowerCase().compareTo(b.userName.toLowerCase()));
      }
      return users;
    }
    catch (e) {
      return null;
    }
  }


  Future<List<User>?> getAllUsers(String username) async {
    try {
      QuerySnapshot querySnapshot = await _db.collection("usuarios").get();
      List<User> users = [];
      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot doc in querySnapshot.docs) {
          User user = User.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
          if (user.userName.toLowerCase().contains(username.toLowerCase())) {
            users.add(user);
          }
        }
        users.sort((a, b) => a.userName.toLowerCase().compareTo(b.userName.toLowerCase()));
      }
      return users;
    }
    catch (e) {
      return null;
    }
  }

}