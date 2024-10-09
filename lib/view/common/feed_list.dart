import 'package:flutter/material.dart';
import 'package:tfg_project/view/editor/preview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controller/feed/feed_controller.dart';
import '../../model/image_model.dart' as model;
import '../../util/date_formats.dart';
import '../../util/snack_bar.dart';
import '../profile/profile.dart';
import 'cirular_image.dart';

class FeedList extends StatelessWidget {
  const FeedList({super.key, required this.feedImages, required this.scaffoldKey, required this.controller, required this.isEditing});

  final List<model.ImageWithUser>? feedImages;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
  final FeedController? controller;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: feedImages?.length ?? 0,
      itemBuilder: (context, index) {
        final imageWithUser = feedImages![index];
        return CustomFeedItem(imageWithUser: imageWithUser, scaffoldKey: scaffoldKey, controller: controller, isEditing: isEditing,);
      },
    );
  }
}


class CustomFeedItem extends StatefulWidget {
  const CustomFeedItem({super.key, required this.imageWithUser, required this.scaffoldKey, required this.controller, required this.isEditing});

  final model.ImageWithUser imageWithUser;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
  final FeedController? controller;
  final bool isEditing;

  @override
  _CustomFeedItemState createState() => _CustomFeedItemState();
}


class _CustomFeedItemState extends State<CustomFeedItem> {

  bool isLiked = false;
  int numLikes = 0;
  late FeedController controller;

  BuildContext? dialogContext;

  Future<void> likeOrDislike() async {
    bool? result = await controller.likeOrDislikeImage(widget.imageWithUser.image, isLiked);
    if (result == true) {
      setState(() {
        if (isLiked) {
          numLikes = numLikes-1;
        }
        else {
          numLikes = numLikes+1;
        }
        isLiked = !isLiked;
      });
    }
    else {
      ShowSnackBar.showSnackBar(widget.scaffoldKey.currentContext!, "Se ha producido un error");
    }
  }

  Future<void> seeLinks() async {
    List<Map<String, String>>? links = widget.imageWithUser.image.links;

    await showDialog(
      context: widget.scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Links'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: links?.length ?? 0,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        setState(() {
                          dialogContext = context;
                        });
                        _launchURL(links[index]['link']!);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                        side: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                      leading: const Icon(
                        Icons.link,
                        size: 24.0,
                        color: Colors.deepOrangeAccent,
                      ),
                      title: Text(
                        links![index]['title'] ?? 'Link ${index + 1}',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (index != links.length - 1)
                      const SizedBox(height: 10,),
                  ],
                );
              },
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
              child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchURL(String urlString) async {
    Uri uri = Uri.parse(urlString);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Navigator.of(dialogContext!).pop();
      ShowSnackBar.showSnackBar(widget.scaffoldKey.currentContext!, ("Imposible abrir $urlString"));
    }
  }

  @override
  void initState() {
    controller = widget.controller ?? FeedController();
    setState(() {
      isLiked = controller.checkIsLiked(widget.imageWithUser.image);
      numLikes = widget.imageWithUser.image.likes?.length ?? 0;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormats.format(widget.imageWithUser.image.creationDate!),
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.deepOrangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10,),
              if (widget.imageWithUser.image.links?.isNotEmpty ?? false)
                TextButton(
                    onPressed: () {
                      seeLinks();
                    },
                    child: const Text(
                      "Ver links",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        decoration: TextDecoration.underline,
                      ),
                    )
                ),
              const Spacer(),
              if (controller.checkIsOwner(widget.imageWithUser.user.id!) && !widget.isEditing)
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Preview(isEditing: true, imageWithUser: widget.imageWithUser)),
                      );
                    },
                    icon: const Icon(Icons.edit)
                )
            ],
          ),
          const SizedBox(height: 6.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: widget.imageWithUser.image.image != null
                ? CachedNetworkImage(
                    imageUrl: widget.imageWithUser.image.image!,
                    placeholder: (context, url) => SizedBox(
                      width: double.infinity,
                      height: screenWidth,
                      child: const Center(child: CircularProgressIndicator(),),
                    ),
                    errorWidget: (context, url, error) => SizedBox(
                      width: double.infinity,
                      height: screenWidth,
                      child: const Center(child: Icon(Icons.error_outline_outlined, size: 50,),),
                    ),
                    imageBuilder: (ctx, img) {
                      return Image(
                          width: double.infinity,
                          fit: BoxFit.cover,
                          image: img
                      );
                    },
                  )
                : Image.memory(
                    widget.imageWithUser.image.decode!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                )
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (!controller.checkIsOwner(widget.imageWithUser.user.id!)) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.imageWithUser.user.id!)),
                    );
                  }
                },
                child: Column(
                  children: [
                    CircularImage(
                      isEditable: false,
                      image: widget.imageWithUser.user.profileImage,
                      scaffoldKey: widget.scaffoldKey,
                      isSmall: true,
                      onImageChanged: null,
                    ),
                    Text(
                      widget.imageWithUser.user.userName,
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15.0),
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      if (!widget.isEditing) {
                        likeOrDislike();
                      }
                    },
                    icon: Icon(
                      Icons.favorite,
                      size: 30,
                      color: isLiked ? Colors.red : Colors.grey,
                    ),
                  ),
                  Text(numLikes.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)
                ],
              ),
              const SizedBox(width: 15.0),
              if (widget.imageWithUser.image.description != null)
                Flexible(
                  child: Text(
                    widget.imageWithUser.image.description!,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}