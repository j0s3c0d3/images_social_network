
import 'package:flutter/material.dart';
import 'package:tfg_project/controller/editor/editor_controller.dart';
import 'package:tfg_project/model/image_model.dart';
import 'package:tfg_project/util/privacity_enum.dart';
import 'package:tfg_project/util/snack_bar.dart';

import '../common/feed_list.dart';

class Preview extends StatefulWidget {
  const Preview({super.key, required this.isEditing, required this.imageWithUser});

  final ImageWithUser imageWithUser;
  final bool isEditing;

  @override
  _PreviewState createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {

  final EditorController controller = EditorController();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController titulo1Controller = TextEditingController();
  final TextEditingController link1Controller = TextEditingController();
  final TextEditingController titulo2Controller = TextEditingController();
  final TextEditingController link2Controller = TextEditingController();
  final TextEditingController titulo3Controller = TextEditingController();
  final TextEditingController link3Controller = TextEditingController();

  late ImageWithUser currentImageWithUser;
  final List<Color> _containerColors = [Colors.white, Colors.white];
  String privacity = Privacity.all.name;
  bool isLoading = false;
  String? privacityText;

  void _changeColor(Color color, int index) {
    setState(() {
      _containerColors[index] = color;
    });
  }

  bool isValidUrl(String text) {
    final RegExp urlRegex = RegExp(
        r"^(https?:\/\/)?"
        r"([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}"
        r"(:[0-9]{1,5})?"
        r"\/?([a-zA-Z0-9-._~:/?#[\]@!$&'()*+,;=%]*)?$");

    return urlRegex.hasMatch(text);
  }

  Future<void> editDescription() async {
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
              child: const Text('Editar', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );

    if (submit == true) {
      setState(() {
        currentImageWithUser.image.description = (textEditingController.text == "") ? null : textEditingController.text;
      });
    }
  }

  Future<void> editLinks() async {
    List<TextEditingController> tituloControllers = [titulo1Controller, titulo2Controller, titulo3Controller];
    List<TextEditingController> linkControllers = [link1Controller, link2Controller, link3Controller];

    bool? submit = await showDialog<bool>(
      context: scaffoldKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Introduce los enlaces y sus títulos'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                for (int i = 0; i < 3; i++)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.deepOrangeAccent,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: tituloControllers[i],
                              decoration: InputDecoration(
                                hintText: 'Título...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(),
                                ),
                              ),
                              maxLength: 30,
                              enabled: true,
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: linkControllers[i],
                              decoration: InputDecoration(
                                hintText: 'Link...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(),
                                ),
                              ),
                              enabled: true,
                            ),
                          ],
                        ),
                      ),
                  )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                for (int i = 0; i < 3; i++) {
                  if (i < (currentImageWithUser.image.links?.length ?? 0)) {
                    tituloControllers[i].text = currentImageWithUser.image.links![i]['title']!;
                    linkControllers[i].text = currentImageWithUser.image.links![i]['link']!;
                  } else {
                    tituloControllers[i].text = "";
                    linkControllers[i].text = "";
                  }
                }
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
      List<Map<String, String>> updatedLinks = [];
      bool anyFails = false;
      for (int i = 0; i < 3; i++) {
        if (tituloControllers[i].text.isNotEmpty && linkControllers[i].text.isEmpty) {
          anyFails = true;
        }
        else if (linkControllers[i].text.isNotEmpty) {
          if (isValidUrl(linkControllers[i].text)) {
            updatedLinks.add({
              'title': tituloControllers[i].text,
              'link': linkControllers[i].text,
            });
          }
          else {
            anyFails = true;
          }
        }
      }
      if (anyFails) {
        for (int i = 0; i < 3; i++) {
          if (i < (currentImageWithUser.image.links?.length ?? 0)) {
            tituloControllers[i].text = currentImageWithUser.image.links![i]['title']!;
            linkControllers[i].text = currentImageWithUser.image.links![i]['link']!;
          } else {
            tituloControllers[i].text = "";
            linkControllers[i].text = "";
          }
        }
        ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "Algunos de los links no son válidos");
      }
      else {
        setState(() {
          currentImageWithUser.image.links = updatedLinks;
        });
      }
    }
  }


  Future<void> deleteImage() async {
    bool? submit = await showDialog<bool>(
      context: scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Estás seguro de que quieres eliminar esta publicación?"),
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
      setState(() {
        isLoading = true;
      });
      bool success = await controller.deleteImage(currentImageWithUser);
      setState(() {
        isLoading = false;
      });
      if (success) {
        Navigator.pushReplacementNamed(
          scaffoldKey.currentContext!, '/home',
          arguments: {'selectedIndex': 3},
        );
      }
      else {
        ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "Se ha producido un error");
      }
    }
  }

  Future<void> publish() async {
    bool? submit = await showDialog<bool>(
      context: scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona el nivel de privacidad de tu publicación'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text("Todo el mundo"),
                    leading: Radio<String>(
                      value: 'all',
                      groupValue: privacity,
                      onChanged: (value) {
                        setState(() {
                          privacity = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text("Amigos"),
                    leading: Radio<String>(
                      value: 'friends',
                      groupValue: privacity,
                      onChanged: (value) {
                        setState(() {
                          privacity = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text("Nadie"),
                    leading: Radio<String>(
                      value: 'none',
                      groupValue: privacity,
                      onChanged: (value) {
                        setState(() {
                          privacity = value!;
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
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
              child: const Text('Publicar', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );

    if (submit == true) {
        setState(() {
          isLoading = true;
        });

        bool success = false;
        if (widget.isEditing) {
          success = await controller.editImage(currentImageWithUser, PrivacityExtension.getPrivacity(privacity));
        } else {
          success = await controller.uploadImage(currentImageWithUser, PrivacityExtension.getPrivacity(privacity));
        }
        setState(() {
          isLoading = false;
        });

        if (success) {
          Navigator.pushReplacementNamed(
            scaffoldKey.currentContext!, '/home',
            arguments: {'selectedIndex': 3},
          );
        }
        else {
          ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "Se ha producido un error");
        }
    }
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

  @override
  void initState() {
    currentImageWithUser = widget.imageWithUser;
    List<TextEditingController> tituloControllers = [titulo1Controller, titulo2Controller, titulo3Controller];
    List<TextEditingController> linkControllers = [link1Controller, link2Controller, link3Controller];
    for (int i = 0; i < (currentImageWithUser.image.links?.length ?? 0) && i < 3; i++) {
      tituloControllers[i].text = currentImageWithUser.image.links![i]['title']!;
      linkControllers[i].text = currentImageWithUser.image.links![i]['link']!;
    }

    textEditingController.text = currentImageWithUser.image.description ?? "";
    if (currentImageWithUser.image.privacity != null) {
      switch (currentImageWithUser.image.privacity!) {
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
        toolbarHeight: MediaQuery.of(context).size.height * 0.09,
        automaticallyImplyLeading: false,
        title: const Text('Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.isEditing) {
              Navigator.of(context).pop();
            }
            else {
              exit();
            }
          },
        ),
        actions: [
          if (widget.isEditing)
            InkWell(
                onTap: () {
                  deleteImage();
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
                        "Eliminar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                )
            ),
          InkWell(
              onTap: () {
                publish();
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
                    child: Icon(
                      Icons.check,
                      size: 17,
                    ),
                  ),
                ),
              )
          ),
        ],
      ),
      body: isLoading
          ? Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.deepOrange),
              )
            )
          : Column(
              children: [
                const SizedBox(height: 10,),
                if (widget.isEditing)
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
                Expanded(child: FeedList(feedImages: [currentImageWithUser], scaffoldKey: scaffoldKey, controller: null, isEditing: true,))
              ],
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  editDescription();
                },
                onTapDown: (_) => _changeColor(Colors.deepOrange, 0),
                onTapUp: (_) => _changeColor(Colors.white, 0),
                onTapCancel: () => _changeColor(Colors.white, 0),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  width: 150,
                  decoration: BoxDecoration(
                    color: _containerColors[0],
                    border: Border.all(
                      color: Colors.deepOrange,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                    child: Text(
                      "Editar descripción",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  editLinks();
                },
                onTapDown: (_) => _changeColor(Colors.deepOrange, 1),
                onTapUp: (_) => _changeColor(Colors.white, 1),
                onTapCancel: () => _changeColor(Colors.white, 1),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  width: 70,
                  decoration: BoxDecoration(
                    color: _containerColors[1],
                    border: Border.all(
                      color: Colors.deepOrange,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                    child: Text(
                      "Links",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }
}