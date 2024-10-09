import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CircularImage extends StatefulWidget {
  const CircularImage({super.key, required this.isEditable, required this.image, required this.scaffoldKey, required this.isSmall, required this.onImageChanged});

  final bool isEditable;
  final bool isSmall;
  final String? image;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
  final Function(Uint8List)? onImageChanged;

  @override
  _CircularImageState createState() => _CircularImageState();
}

class _CircularImageState extends State<CircularImage> {

  Uint8List? decode;
  bool initialImageDeleted = false;
  
  final picker = ImagePicker();

  Future<Uint8List?> selectImage(mode, context) async {

    XFile? pickedImage;

    // Cuando se hace una foto
    if (mode == 0) {
      pickedImage = await picker.pickImage(source: ImageSource.camera);
    }

    // Cuando se escoge de la galería
    if (mode == 1) {
      pickedImage = await picker.pickImage(source: ImageSource.gallery);
    }

    if (pickedImage != null) {
      final result = await pickedImage.readAsBytes();
      return result;
    }
    return null;
  }

  void handleButtonPressed() async {
    Uint8List? uint8List;
    bool canDelete = (widget.image != null && !initialImageDeleted) || decode != null;

    uint8List = await showDialog<Uint8List?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (canDelete)
                  ListTile(
                    title: const Text('Eliminar imagen actual'),
                    onTap: () {
                      Navigator.of(context).pop(Uint8List(0));
                    },
                  ),
                ListTile(
                  title: const Text('Tomar foto'),
                  onTap: () async {
                    Navigator.of(context).pop(await selectImage(0, context));
                  },
                ),
                ListTile(
                  title: const Text('Seleccionar de la galería'),
                  onTap: () async {
                    Navigator.of(context).pop(await selectImage(1, context));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (uint8List != null) {
      widget.onImageChanged!(uint8List);
      if (uint8List.isNotEmpty) {
        setState(() {
          decode = uint8List;
        });
      }
      else {
        setState(() {
          decode = null;
          if (widget.image != null && !initialImageDeleted) {
            initialImageDeleted = true;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final double avatarRadius = widget.isSmall ? 30.0 : 55.0;

    return Stack(
      children: [
        decode != null && decode!.isNotEmpty
            ? CircleAvatar(
                radius: avatarRadius,
                backgroundImage: MemoryImage(decode!)
              )
            : widget.image == null || initialImageDeleted
              ? CircleAvatar(
                  radius: avatarRadius,
                  backgroundImage: const AssetImage('assets/profileImage.png')
                )
              : CircleAvatar(
                  radius: avatarRadius,
                  backgroundImage: NetworkImage(widget.image!)
                ),

        if(widget.isEditable)
          Positioned(
            bottom: -10,
            left: 70,
            child: IconButton(
                iconSize: 25,
                onPressed: handleButtonPressed,
                icon: const Icon(Icons.add_a_photo)
            )
          ),
      ],
    );
  }
}