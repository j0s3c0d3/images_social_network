import 'package:flutter/material.dart';
import 'package:tfg_project/controller/feed/explore_controller.dart';
import 'package:tfg_project/model/user_model.dart';

import '../common/cirular_image.dart';
import '../common/follow_button.dart';
import '../profile/profile.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {

  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final ExploreController controller = ExploreController();

  late Future<List<User>?> userList;
  late String currentUserId;
  bool searchSelected = false;
  String? searchText;

  Future<List<User>?> future(String? userName) async {
    return await controller.getFollowedUsers(userName);
  }

  Future<List<User>?> getAllUsers(String userName) async {
    return await controller.getAllUsers(userName);
  }

  @override
  void initState() {
    currentUserId = controller.currentUserId();
    userList = future(null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
        title: const Text('Buscar'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Filtrar por nombre de usuario...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  searchText = val;
                  if (searchSelected) {
                    if (searchText != null && searchText!.isNotEmpty) {
                      userList = getAllUsers(searchText!);
                    }
                  }
                  else {
                    userList = future(searchText == "" ? null : searchText);
                  }
                });
              },
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child:  Row(
            children: [
              Expanded(child: GestureDetector(
                onTap: () {
                  setState(() {
                    searchSelected = false;
                    userList = future(searchText == "" ? null : searchText);
                  });
                },
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: searchSelected ? Colors.black : Colors.white,
                      border: Border.all(
                        color: searchSelected ? Colors.white : Colors.black,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Center(
                      child: Text(
                        "En su lista de amigos",
                        style: TextStyle(
                            color: searchSelected ? Colors.white : Colors.deepOrange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                ),
              )),
              Expanded(child: GestureDetector(
                onTap: () {
                  setState(() {
                    searchSelected = true;
                    if (searchText != null && searchText!.isNotEmpty) {
                      userList = getAllUsers(searchText!);
                    }
                  });
                },
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: !searchSelected ? Colors.black : Colors.white,
                      border: Border.all(
                        color: !searchSelected ? Colors.white : Colors.black,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Center(
                      child: Text(
                        "Buscar",
                        style: TextStyle(
                            color: !searchSelected ? Colors.white : Colors.deepOrange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                ),
              )),
            ],
          ),),
          const SizedBox(height: 6,),
          FutureBuilder(
              future: userList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return const Expanded(child: Center(
                      child: Text(
                        "Se ha producido un error",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),);
                  }
                  else if (snapshot.hasData) {
                    if (searchSelected &&
                        (searchText == null || searchText!.isEmpty)) {
                      return const Expanded(child: Center(
                        child: Text(
                          "Comienza a escribir para iniciar la búsqueda",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ),);
                    }
                    else {
                      if (snapshot.data!.isEmpty) {
                        return const Expanded(child: Center(
                          child: Text(
                            "No se encuentran resultados",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ),);
                      }
                      else {
                        return Expanded(
                          child: ListView.builder(
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
                                          userList = future(searchText == "" ? null : searchText);
                                        });
                                      });
                                    },
                                  ) : ListTile(
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
                    }
                  }
                  else {
                    return const Expanded(child: Center(
                      child: Text(
                        "No se encuentran resultados",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),);
                  }
                }
                else {
                  return const Expanded(child: Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  ),);
                }
              }
          )
        ],
      ),
    );
  }
}