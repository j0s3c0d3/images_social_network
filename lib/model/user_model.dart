import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserModel extends ChangeNotifier {

  User? _user;
  User? get user => _user;
  set user(User? user) {
    _user = user;
    notifyListeners();
  }

}

class User {
  String? id;
  String userName;
  String? email;
  String? profileImage;
  List<String>? followers;
  DateTime? birthDate;
  Uint8List? profileImageFile; // No está en Firestore
  String? password; // No está en Firestore

  User({
    this.id,
    required this.userName,
    this.password,
    this.email,
    this.profileImage,
    this.profileImageFile,
    this.followers,
    this.birthDate
  });

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    List<String>? followers = [];
    if (data?['followers'] != null) {
      data?['followers'].forEach((follower) {
        followers.add(follower.toString());
      });
    }
    return User(
      id: data?['id'],
      userName: data?['userName'],
      email: data?['email'],
      profileImage: data?['profileImage'],
      birthDate: data?['birthDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data?['birthDate'].millisecondsSinceEpoch)
          : null,
      followers: followers,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      "userName": userName,
      if (email != null) "email": email,
      if (profileImage != null) "profileImage": profileImage,
      if (birthDate != null) "birthDate": birthDate
    };
  }

}

