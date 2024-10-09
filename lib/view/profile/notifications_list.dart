import 'package:flutter/material.dart';
import 'package:tfg_project/controller/profile/notifications_list_controller.dart';
import 'package:tfg_project/model/image_model.dart';
import 'package:tfg_project/view/profile/image_detail.dart';
import 'package:tfg_project/view/profile/profile.dart';

import '../../model/notification_model.dart';
import '../../util/snack_bar.dart';

class NotificationsList extends StatelessWidget {
  NotificationsList({super.key, required this.newNotifications, required this.oldNotifications});

  final List<UserNotification> newNotifications;
  final List<UserNotification> oldNotifications;

  final NotificationsListController controller = NotificationsListController();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> handleTrailingPressed(String userId, String? imageId) async {
    if (imageId == null) {
      Navigator.of(scaffoldKey.currentContext!).push(
        MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)),
      );
    }
    else {
      String? goTo = await showDialog<String>(
        context: scaffoldKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 20),
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pop("perfil");
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                              side: BorderSide(color: Colors.grey.withOpacity(0.5)),
                            ),
                            leading: const Icon(
                              Icons.person,
                              size: 24.0,
                              color: Colors.deepOrangeAccent,
                            ),
                            title: const Text(
                              "Ir al perfil del usuario",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pop("imagen");
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                              side: BorderSide(color: Colors.grey.withOpacity(0.5)),
                            ),
                            leading: const Icon(
                              Icons.image,
                              size: 24.0,
                              color: Colors.deepOrangeAccent,
                            ),
                            title: const Text(
                              "Ir a la publicación",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                  )
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );


      if (goTo == "imagen") {
        ImageWithUser? imageWithUser = await controller.getImageWithUser(imageId);
        if (imageWithUser == null) {
          ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "Se ha producido un error");
        } else {
          Navigator.of(scaffoldKey.currentContext!).push(
            MaterialPageRoute(builder: (context) => ImageDetail(imageWithUser: imageWithUser, isOwner: true)),
          );
        }
      }
      else if (goTo == "perfil") {
        Navigator.of(scaffoldKey.currentContext!).push(
          MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final appBarHeight = MediaQuery.of(context).size.height * 0.09;

    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
        title: const Text('Notificaciones'),
      ),
      body: Container(
        color: Colors.black,
        child: (newNotifications.isEmpty && oldNotifications.isEmpty)
            ? const Center(
                child: Text(
                  "Todavía no tienes ninguna notificación",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2 - 20 - appBarHeight,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.deepOrange,
                          width: 3.0,
                        ),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: _buildSection('Nuevas', newNotifications),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2 - 20 - appBarHeight,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.deepOrange,
                          width: 3.0,
                        ),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: _buildSection('Antiguas', oldNotifications),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSection(String title, List<UserNotification> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        if (notifications.isNotEmpty)
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final title = notification.imageId == null ? "Tienes un nuevo amigo" : "Alguien ha dado like a tu publicación";
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                        color: Colors.deepOrange,
                        width: 3.0,
                      ),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          handleTrailingPressed(notification.senderId!, notification.imageId);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.deepOrange),
                          shape: MaterialStateProperty.all<CircleBorder>(
                            const CircleBorder(),
                          ),
                        ),
                        child: const Icon(Icons.navigate_next, color: Colors.white,),
                      ),
                    ),
                  )
                );
              },
            ),
          ),
        if (notifications.isEmpty)
          const Expanded(
              child: Center(child: Text("No tienes notificaciones en este apartado",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17),),)
          )
      ],
    );
  }
}
