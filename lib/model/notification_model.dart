import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotification {
  String? id; // Este id es el doc
  String? imageId;
  String? senderId;
  String? recipientId;
  bool? active;
  DateTime? creationDate;

  UserNotification({
    this.id,
    this.imageId,
    this.senderId,
    this.recipientId,
    this.active,
    this.creationDate
  });

  factory UserNotification.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return UserNotification(
      imageId: data?['imageId'],
      senderId: data?['senderId'],
      recipientId: data?['recipientId'],
      active: data?['active'],
      creationDate: data?['creationDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data?['creationDate'].millisecondsSinceEpoch)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (imageId != null) "imageId": imageId,
      "senderId": senderId,
      "recipientId": recipientId,
      "active": active,
      "creationDate": creationDate
    };
  }

}