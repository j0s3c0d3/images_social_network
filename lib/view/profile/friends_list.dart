import 'package:flutter/material.dart';
import 'package:tfg_project/controller/profile/friends_list_controller.dart';
import 'package:tfg_project/view/common/follow_button.dart';
import 'package:tfg_project/view/profile/profile.dart';

import '../../model/user_model.dart';
import '../common/cirular_image.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({super.key, required this.followers});

  final List<String> followers;

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  final FriendsListController controller = FriendsListController();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  late Future<List<User>> _future;
  late String currentUserId;

  @override
  void initState() {
    _future = future();
    currentUserId = controller.currentUserId();
    super.initState();
  }

  Future<List<User>> future() async {
    return controller.getFollowers(widget.followers);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Scaffold(
              key: scaffoldKey,
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                automaticallyImplyLeading: false,
                title: const Text('Amigos'),
              ),
              body: const Center(
                child: Text(
                  "Se ha producido un error",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Scaffold(
                key: scaffoldKey,
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  automaticallyImplyLeading: false,
                  title: const Text('Amigos'),
                ),
                body: const Center(
                  child: Text(
                    "Se ha producido un error",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
              );
            } else {
              return Scaffold(
                key: scaffoldKey,
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  automaticallyImplyLeading: false,
                  title: const Text('Amigos'),
                ),
                body: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    User user = snapshot.data![index];
                    bool isFollowing = controller.checkFriendship(user.followers ?? []);

                    return Column(
                      children: [
                        currentUserId != user.id! ? ListTile(
                          leading: CircularImage(
                            isEditable: false,
                            isSmall: true,
                            image: user.profileImage,
                            onImageChanged: null,
                            scaffoldKey: scaffoldKey,
                          ),
                          title: Text(user.userName),
                          trailing: FollowButton(
                            scaffoldKey: scaffoldKey,
                            isSmall: true,
                            isFollowing: isFollowing,
                            onButtonPressed: (isFollowing) => controller.followOrUnfollow(user.id!, isFollowing)
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => ProfilePage(userId: user.id)),
                            ).then((value) {
                              setState(() {
                                _future = future();
                              });
                            });
                          },
                        )
                        : ListTile(
                          leading: CircularImage(
                            isEditable: false,
                            isSmall: true,
                            image: user.profileImage,
                            onImageChanged: null,
                            scaffoldKey: scaffoldKey,
                          ),
                          title: Text(user.userName),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              );
            }
          } else {
            return Scaffold(
              key: scaffoldKey,
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                automaticallyImplyLeading: false,
                title: const Text('Amigos'),
              ),
              body: const Center(
                child: Text(
                  "Se ha producido un error",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            );
          }
        } else {
          return Scaffold(
            key: scaffoldKey,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              automaticallyImplyLeading: false,
              title: const Text('Amigos'),
            ),
            body: Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.deepOrange),
              ),
            ),
          );
        }
      },
    );
  }
}