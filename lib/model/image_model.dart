import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_project/model/user_model.dart';

import '../util/privacity_enum.dart';

class Image {
  String? image;
  String? userId;
  String? description;
  DateTime? creationDate;
  List<String>? likes;
  Privacity? privacity;
  Uint8List? decode; // No está en Firebase
  List<Map<String, String>>? links;

  Image({
    this.decode,
    this.image,
    this.userId,
    this.description,
    this.creationDate,
    this.likes,
    this.privacity,
    this.links
  });

  factory Image.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    List<String>? likes = [];
    if (data?['likes'] != null) {
      data?['likes'].forEach((like) {
        likes.add(like.toString());
      });
    }
    List<Map<String, String>>? linksData = [];
    if (data?['links'] != null) {
      data?['links'].forEach((link) {
        linksData.add({
          'title': link['title'].toString(),
          'link': link['link'].toString()
        });
      });
    }
    return Image(
        image: data?['image'],
        userId: data?['userId'],
        creationDate: data?['creationDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data?['creationDate'].millisecondsSinceEpoch)
            : null,
        description: data?['description'],
        likes: likes,
        privacity: PrivacityExtension.getPrivacity(data?['privacity']),
        links: linksData
    );
  }

  Map<String, dynamic> toFirestore() {
    List<Map<String, String>> linksData = [];

    if (links != null) {
      for (Map<String, String> link in links!) {
        if (link.containsKey('title') && link.containsKey('link')) {
          linksData.add({
            'title': link['title']!,
            'link': link['link']!
          });
        }
      }
    }


    return {
      "image": image,
      "userId": userId,
      "description": description,
      "creationDate": creationDate,
      "privacity": privacity?.name,
      "links": linksData
    };
  }
}


class ImageWithUser {
  Image image;
  User user;

  ImageWithUser({required this.image, required this.user});
}