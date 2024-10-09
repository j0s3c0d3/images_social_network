import 'package:flutter/material.dart';
import 'package:tfg_project/model/image_model.dart' as model;
import 'package:tfg_project/util/privacity_enum.dart';
import 'package:tfg_project/view/common/feed_list.dart';
import 'package:tfg_project/view/profile/image_detail.dart';

import '../../controller/profile/profile_controller.dart';
import '../../model/user_model.dart';

class ProfileImageList extends StatefulWidget {
  const ProfileImageList({super.key, required this.user, required this.isFollower, required this.isBig,
    required this.scaffoldKey});

  final User user;
  final bool isFollower;
  final bool isBig;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;

  @override
  _ProfileImageListState createState() => _ProfileImageListState();
}


class _ProfileImageListState extends State<ProfileImageList> {

  final ProfileController controller = ProfileController();

  late Future<List<model.Image>?> images;

  Future<List<model.Image>?> future() async {
    return await controller.getUserImages(widget.user.id);
  }

  @override
  void initState() {
    images = future();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: images,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Expanded(child: Center(
              child: Text(
                "Se ha producido un error",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20
                ),
              ),
            ));
          } else if (snapshot.hasData) {
            if (snapshot.data == null) {
              return const Expanded(child: Center(
                child: Text(
                  "Se ha producido un error",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20
                  ),
                ),
              ));
            }
            else if (snapshot.data!.isEmpty) {
              return const Expanded(child: Center(
                child: Text(
                  "No hay fotos",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20
                  ),
                ),
              ));
            }
            else {
              if (widget.user.id == controller.getOwnUser().id) {
                List<model.ImageWithUser> profileImages = [];
                for (model.Image img in snapshot.data!) {
                  model.ImageWithUser imgWithUsr = model.ImageWithUser(image: img, user: widget.user);
                  profileImages.add(imgWithUsr);
                }
                if (widget.isBig) {
                  return Expanded(child: FeedList(feedImages: profileImages, scaffoldKey: widget.scaffoldKey, controller: null, isEditing: false,));
                }
                else {
                  return ImageList(images: snapshot.data!, onImagePressed: (ind) {
                    Navigator.of(widget.scaffoldKey.currentContext!).push(
                      MaterialPageRoute(builder: (context) => ImageDetail(imageWithUser: profileImages[ind], isOwner: false)),
                    ).then((value) {
                      setState(() {
                        images = future();
                      });
                    });
                  },);
                }
              }
              else {
                List<model.Image> finalImages = [];
                for (model.Image image in snapshot.data!) {
                  if (image.privacity == Privacity.all) {
                    finalImages.add(image);
                  }
                  else if (image.privacity == Privacity.friends) {
                    if (widget.isFollower) {
                      finalImages.add(image);
                    }
                  }
                }
                if (finalImages.isEmpty) {
                  return const Expanded(child: Center(
                    child: Text(
                      "No hay fotos",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20
                      ),
                    ),
                  ));
                }
                else {
                  List<model.ImageWithUser> profileImages = [];
                  for (model.Image img in finalImages) {
                    model.ImageWithUser imgWithUsr = model.ImageWithUser(image: img, user: widget.user);
                    profileImages.add(imgWithUsr);
                  }
                  if (widget.isBig) {
                    return Expanded(child: FeedList(feedImages: profileImages, scaffoldKey: widget.scaffoldKey, controller: null, isEditing: false,));
                  }
                  else {
                    return ImageList(images: finalImages, onImagePressed: (ind) {
                      Navigator.of(widget.scaffoldKey.currentContext!).push(
                        MaterialPageRoute(builder: (context) => ImageDetail(imageWithUser: profileImages[ind], isOwner: false)),
                      ).then((value) {
                        setState(() {
                          images = future();
                        });
                      });
                    },);
                  }
                }
              }
            }
          } else {
            return const Expanded(child: Center(
              child: Text(
                "No hay fotos",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20
                ),
              ),
            ));
          }
        } else {
          return Expanded(
            child: Container(
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


class ImageList extends StatelessWidget {
  const ImageList({super.key, required this.images, required this.onImagePressed});

  final List<model.Image> images;
  final Function(int) onImagePressed;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Número de imágenes por fila
        crossAxisSpacing: 2, // Espacio horizontal entre imágenes
        mainAxisSpacing: 2, // Espacio vertical entre imágenes
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            onImagePressed(index);
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(images[index].image!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}