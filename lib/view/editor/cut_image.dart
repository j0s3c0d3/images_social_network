import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:tfg_project/model/image_model.dart' as imageModel;
import 'package:tfg_project/view/editor/preview.dart';

import '../../controller/editor/editor_controller.dart';

class CutImage extends StatefulWidget {
  const CutImage({super.key, required this.image});

  final Uint8List image;

  @override
  _CutImageState createState() => _CutImageState();
}

class _CutImageState extends State<CutImage> {

  final EditorController controller = EditorController();
  final imageCropper = ImageCropper();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController textEditingController = TextEditingController();

  late Future<Uint8List> croppedImage;
  Color _containerColor = Colors.white;
  Uint8List? lastCroppedImage;

  Future<Uint8List> _cropImage() async {

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/image.png').create();
    file.writeAsBytesSync(widget.image);

    final croppedFile = await imageCropper.cropImage(
      sourcePath: file.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      compressFormat: ImageCompressFormat.png,
      compressQuality: 100,
      uiSettings: [
        IOSUiSettings(
            title: 'Recortar imagen',
        ),
        AndroidUiSettings(
            toolbarTitle: 'Recortar imagen',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false
        ),
      ]
    );

    final Uint8List? croppedImageBytes = await croppedFile?.readAsBytes();
    file.delete();
    if (croppedImageBytes != null) {
      setState(() {
        lastCroppedImage = croppedImageBytes;
      });
      return croppedImageBytes;
    }
    return (lastCroppedImage ?? widget.image);
  }

  void _changeColor(Color color) {
    setState(() {
      _containerColor = color;
    });
  }

  void exit() async {
    bool? submit = await showDialog<bool>(
      context: scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Perderás los últimos cambios realizados', style: TextStyle(fontSize: 20)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (submit == true) {
      Navigator.of(scaffoldKey.currentContext!).pop();
    }
  }

  Future<void> addDescription() async {
    bool? submit = await showDialog<bool>(
      context: scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextField(
            controller: textEditingController,
            maxLines: 5,
            decoration: const InputDecoration(
              suffixIcon: Icon(
                Icons.edit,
              ),
              filled: true,
              hintText: 'Puedes añadir aquí una descripción a tu publicación',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange
              ),
              child: const Text('Aceptar', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );

    if (submit == true) {
      imageModel.ImageWithUser imageWithUser = controller.createImageWithUser(textEditingController.text, (lastCroppedImage ?? widget.image));
      Navigator.of(scaffoldKey.currentContext!).push(
        MaterialPageRoute(builder: (context) => Preview(isEditing: false, imageWithUser: imageWithUser)));
    }
    else{
      setState(() {
        textEditingController.clear();
      });
    }
  }

  @override
  void initState() {
    croppedImage = _cropImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white12,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.09,
        automaticallyImplyLeading: false,
        title: const Text('Recortar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            exit();
          },
        ),
        actions: [
          InkWell(
              onTap: () {
                addDescription();
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.shade200,
                        spreadRadius: 1.5,
                        blurRadius: 6.0,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Siguiente",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              )
          )
        ],
      ),
      body: Center(
        child: FutureBuilder(
            future: croppedImage,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Text("Se ha producido un error");
                }
                else if (snapshot.hasData) {
                  return Image.memory(snapshot.data!, fit: BoxFit.fitHeight,);
                }
                else {
                  return const Text("Se ha producido un error");
                }
              }
              else {
                return const CircularProgressIndicator(color: Colors.deepOrange);
              }
            }
        ),
      ),
      bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(6.0),
          ),
          height: 70,
          child: Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  croppedImage = _cropImage();
                });
              },
              onTapDown: (_) => _changeColor(Colors.deepOrange),
              onTapUp: (_) => _changeColor(Colors.white),
              onTapCancel: () => _changeColor(Colors.white),
              child: Container(
                margin: const EdgeInsets.all(10),
                width: 85,
                decoration: BoxDecoration(
                  color: _containerColor,
                  border: Border.all(
                    color: Colors.deepOrange,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Center(
                  child: Text(
                    "Reintentar",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          )
      ),
    );
  }
}
