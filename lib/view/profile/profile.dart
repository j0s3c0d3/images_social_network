import 'package:flutter/material.dart';
import 'package:tfg_project/controller/profile/profile_controller.dart';
import 'package:tfg_project/model/user_model.dart';
import 'package:tfg_project/view/common/cirular_image.dart';
import 'package:tfg_project/view/common/follow_button.dart';
import 'package:tfg_project/view/profile/notifications_list.dart';
import 'package:tfg_project/view/profile/profile_image_list.dart';

import '../../model/notification_model.dart';
import 'friends_list.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.userId, this.homeScaffoldKey});

  final String? userId;
  final GlobalKey<ScaffoldMessengerState>? homeScaffoldKey;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final ProfileController controller = ProfileController();

  late Future<User?> user;
  bool following = false;

  Future<User?> future() async {
    final userProfileFuture = controller.getUserProfile(widget.userId);
    final userProfile = await userProfileFuture;
    if (widget.userId != null) {
      setState(() {
        following = controller.checkFriendship(userProfile?.followers ?? []);
      });
    }
    return userProfile;
  }

  @override
  void initState() {
    user = future();
    super.initState();
  }

  Future<bool> onFollowPressed(bool isFollowing) async {
    bool result = await controller.followOrUnfollow(widget.userId!, isFollowing);
    setState(() {
      user = future();
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text("Se ha producido un error");
          } else if (snapshot.hasData) {
            if (snapshot.data == null) {
              return const Text("Se ha producido un error");
            }
            else {
              final userProfile = snapshot.data as User;

              if (widget.userId != null) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text("Usuario"),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    automaticallyImplyLeading: false,
                  ),
                  key: scaffoldKey,
                  body: Profile(
                    owner: false,
                    userProfile: userProfile,
                    following: following,
                    scaffoldKey: scaffoldKey,
                    onFollowPressed: onFollowPressed,
                  ),
                );
              }
              else {
                return Profile(
                    owner: true,
                    userProfile: userProfile,
                    following: following,
                    scaffoldKey: widget.homeScaffoldKey!,
                    onFollowPressed: null,
                );
              }
            }
          } else {
            return const Text("Se ha producido un error");
          }
        } else {
          return Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: const Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
          );
        }
      },
    );
  }
}




class Profile extends StatefulWidget {
  const Profile({
    super.key,
    required this.owner,
    required this.following,
    required this.userProfile,
    required this.scaffoldKey,
    required this.onFollowPressed,
  });

  final bool owner;
  final bool following;
  final User userProfile;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
  final Future<bool> Function(bool)? onFollowPressed;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  bool bigImageList = false;
  List<bool> _isSelected = [true, false];
  late User currentUserProfile;

  final ProfileController controller = ProfileController();

  @override
  void didUpdateWidget(Profile oldWidget) {
    if (oldWidget.userProfile != widget.userProfile) {
      setState(() {
        currentUserProfile = widget.userProfile;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    currentUserProfile = widget.userProfile;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!bigImageList)
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.25,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularImage(
                      isEditable: false,
                      image: currentUserProfile.profileImage,
                      scaffoldKey: widget.scaffoldKey,
                      isSmall: false,
                      onImageChanged: null,
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (currentUserProfile.followers?.isNotEmpty ?? false) {
                          Navigator.of(widget.scaffoldKey.currentContext!).push(
                            MaterialPageRoute(builder: (context) => FriendsList(followers: currentUserProfile.followers!,)),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          Text(
                            currentUserProfile.followers?.length.toString() ?? "0",
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 5),
                          const Text('amigos'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (!widget.owner)
                      FollowButton(
                        scaffoldKey: widget.scaffoldKey,
                        isSmall: false,
                        onButtonPressed: widget.onFollowPressed!,
                        isFollowing: widget.following,
                      ),
                    if (widget.owner)
                      NotificationsButton(scaffoldKey: widget.scaffoldKey, userId: controller.getOwnUser().id!, controller: controller, )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    currentUserProfile.userName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Divider(thickness: 2.0, color: Colors.deepOrangeAccent,),),
              ],
            ),
          ),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: bigImageList ? const EdgeInsets.fromLTRB(5.0, 15.0, 0, 0) : const EdgeInsets.symmetric(horizontal: 10.0),
                child: ToggleButtons(
                  isSelected: _isSelected,
                  onPressed: (int ind) {
                    if (ind == 0) {
                      setState(() {
                        bigImageList = false;
                      });
                    }
                    else {
                      setState(() {
                        bigImageList = true;
                      });
                    }
                    setState(() {
                      _isSelected = List.generate(_isSelected.length, (i) => i == ind);
                    });
                  },
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      child: const Text("Normal", style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0
                      ),),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      child: const Text("Grande", style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0
                      ),),
                    ),
                  ],
                ),
            ),
            const SizedBox(height: 10,),
            ProfileImageList(user: widget.owner ? controller.getOwnUser() : currentUserProfile,
              isFollower: widget.following, isBig: bigImageList, scaffoldKey: widget.scaffoldKey,),
          ],
        ))
      ],
    );
  }
}



class NotificationsButton extends StatefulWidget {
  const NotificationsButton({super.key, required this.scaffoldKey, required this.userId, required this.controller});

  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
  final String userId;
  final ProfileController controller;

  @override
  _NotificationsButtonState createState() => _NotificationsButtonState();
}

class _NotificationsButtonState extends State<NotificationsButton> {

  late Future<List<UserNotification>> notifications;

  Future<List<UserNotification>> future() async {
    return await widget.controller.getUserNotifications(widget.userId);
  }

  @override
  void initState() {
    notifications = future();
    super.initState();
  }

  Future<void> handlePressed(List<UserNotification> newNotifications, List<UserNotification> oldNotifications) async {
    Navigator.of(widget.scaffoldKey.currentContext!).push(
      MaterialPageRoute(builder: (context) => NotificationsList(newNotifications: newNotifications, oldNotifications: oldNotifications)),
    ).then((value) async {
      for (UserNotification notification in newNotifications) {
        await widget.controller.deactivateNotification(notification.id!);
      }
      setState(() {
        notifications = future();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return ElevatedButton(
                onPressed: () {
                  handlePressed([], []);
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<CircleBorder>(
                    const CircleBorder(),
                  ),
                ),
                child: const Icon(Icons.notifications, size: 30,),
              );
            }
            else if (snapshot.hasData) {
              List<UserNotification> newNotifications = [];
              List<UserNotification> oldNotifications = [];
              for (UserNotification notification in snapshot.data!) {
                if (notification.active!) {
                  newNotifications.add(notification);
                }
                else {
                  oldNotifications.add(notification);
                }
              }

              if (newNotifications.isEmpty) {
                return ElevatedButton(
                  onPressed: () {
                    handlePressed(newNotifications, oldNotifications);
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<CircleBorder>(
                      const CircleBorder(),
                    ),
                  ),
                  child: const Icon(Icons.notifications, size: 30,),
                );
              }
              else {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        handlePressed(newNotifications, oldNotifications);
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<CircleBorder>(
                          const CircleBorder(),
                        ),
                      ),
                      child: const Icon(Icons.notifications, size: 30,),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 15,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                );
              }
            }
            else {
              return ElevatedButton(
                onPressed: () {
                  handlePressed([], []);
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<CircleBorder>(
                    const CircleBorder(),
                  ),
                ),
                child: const Icon(Icons.notifications, size: 30,),
              );
            }
          }
          else {
            return ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                shape: MaterialStateProperty.all<CircleBorder>(
                  const CircleBorder(),
                ),
              ),
              child: const Icon(Icons.notifications, size: 30,),
            );
          }
        }
    );
  }
}