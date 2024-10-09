import 'package:tfg_project/model/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class NotificationService {

  final _db = FirebaseFirestore.instance;

  Future<List<UserNotification>?> getUserNotifications(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _db.collection("notificaciones").where("recipientId", isEqualTo: userId).get();
      List<UserNotification> notifications = [];
      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot doc in querySnapshot.docs) {
          UserNotification userNotification = UserNotification.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
          userNotification.id = doc.id;
          notifications.add(userNotification);
        }
      }
      notifications.sort((a, b) => (b.creationDate ?? DateTime.now()).compareTo(a.creationDate ?? DateTime.now()));
      return notifications;
    }
    catch (e) {
      return null;
    }
  }

  Future<bool> addNotification(String recipientId, String senderId, String? imageId) async {
    try {
      await removeNotification(senderId, recipientId, imageId);
      final notification = UserNotification(
        imageId: imageId,
        recipientId: recipientId,
        senderId: senderId,
        active: true,
        creationDate: DateTime.now(),
      );
      await _db.collection("notificaciones").add(notification.toFirestore());
      return true;
    }
    catch (e) {
      return false;
    }
  }


  Future<bool> deactivateNotification(String id) async {
    try {
      final notificationRef = _db.collection("notificaciones").doc(id);
      final notificationSnapshot = await notificationRef.get();

      if (notificationSnapshot.exists) {
        await notificationRef.update({'active': false});
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeNotification(String senderId, String recipientId, String? imageId) async {
    try {
      final existingNotificationQuery = await _db.collection("notificaciones")
          .where("recipientId", isEqualTo: recipientId)
          .where("senderId", isEqualTo: senderId)
          .where("imageId", isEqualTo: imageId)
          .get();
      if (existingNotificationQuery.docs.isNotEmpty) {
        for (final doc in existingNotificationQuery.docs) {
          await doc.reference.delete();
        }
        return true;
      }
      else {
        return false;
      }
    }
    catch (e) {
      return false;
    }
  }

}