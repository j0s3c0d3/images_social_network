import 'package:flutter/material.dart';

import '../../model/image_model.dart';
import '../../util/privacity_enum.dart';
import '../common/feed_list.dart';

class ImageDetail extends StatefulWidget {
  const ImageDetail({super.key, required this.imageWithUser, required this.isOwner});

  final ImageWithUser imageWithUser;
  final bool isOwner;

  @override
  _ImageDetailState createState() => _ImageDetailState();
}


class _ImageDetailState extends State<ImageDetail> {

  String? privacityText;
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    if (widget.imageWithUser.image.privacity != null) {
      switch (widget.imageWithUser.image.privacity!) {
        case Privacity.all:
          privacityText = "Actualmente cualquier usuario puede ver esta publicación";
          break;
        case Privacity.none:
          privacityText = "Actualmente solo tú puedes ver esta publicación";
          break;
        case Privacity.friends:
          privacityText = "Actualmente tus amigos pueden ver esta publicación";
          break;
      }
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white12,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Publicación"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10,),
          if (widget.isOwner)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                privacityText!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          Expanded(child: FeedList(feedImages: [widget.imageWithUser], scaffoldKey: scaffoldKey, controller: null, isEditing: false,)),
        ],
      ),
    );
  }
}