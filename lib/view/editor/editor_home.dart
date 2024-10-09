import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditorHomePage extends StatelessWidget {
  EditorHomePage({super.key, required this.scaffoldKey});

  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
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

  Future<void> uploadImage() async {
    Uint8List? uint8List;

    uint8List = await showDialog<Uint8List?>(
      context: scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
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
      if (uint8List.isNotEmpty) {
        Navigator.pushReplacementNamed(
          scaffoldKey.currentContext!, '/editor',
          arguments: {'image': uint8List},
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/editorBackground.png',
          fit: BoxFit.cover,
        ),
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sube una imagen para empezar a editar!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.deepOrange,
                      offset: Offset(2, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  uploadImage();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                ),
                child: const Text(
                  'Empezar',
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}