import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tfg_project/util/image_filters.dart';
import 'package:tfg_project/util/snack_bar.dart';
import 'package:tfg_project/view/editor/cut_image.dart';
import 'package:tfg_project/view/editor/editor_options/adjust_option.dart';
import 'package:tfg_project/view/editor/editor_options/filter_options.dart';
import 'package:tfg_project/view/editor/editor_options/text_option.dart';
import 'dart:ui' as ui;


class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  _EditorPageState createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {

  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final GlobalKey _globalKey = GlobalKey();
  final TextEditingController textEditingController = TextEditingController();

  List<Widget> _editOptions() => <Widget>[
    FilterOption(onFilterChanged: (newFilter) { onFilterTapped(newFilter);},
      currentFilter: filter,
    ),
    TextOption(onTextAdded: () { addText(); },
      isTextSelected: selectedText != null,
      onTextRemoved: () { removeText(); },
      onTextEdited: () { editText(); },
      onTextBigger: () { biggerText(); },
      onTextSmaller: () { smallerText(); },
      onTextBold: () { boldText(); },
      onTextItalic: () { italicText(); },
    ),
    AdjustOption(onAdd: (newColor) { changeImageColor(newColor); },
      onRemove: () { cleanImageColor(); },
      image: image,
      currentColor: imageColor,
    )
  ];

  late Uint8List image;
  bool isFirstTime = true;
  int _selectedIndex = 0;
  ColorFilter filter = ImageFilters.neutral;
  List<TextInfo> texts = [];
  late Future<double> imageWidth;
  int? selectedText;
  Color? imageColor;

  void exit() async {
    bool? submit = await showDialog<bool>(
      context: scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Si sales ahora perderás los cambios que hayas realizado', style: TextStyle(fontSize: 20)),
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
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );

    if (submit == true) {
      Navigator.pushReplacementNamed(
        scaffoldKey.currentContext!, '/home',
        arguments: {'selectedIndex': 2},
      );
    }
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (selectedText != null) {
        texts[selectedText!].isSelected = false;
        selectedText = null;
      }
    });
  }

  Future<Uint8List?> _applyFilterAndGetBytes() async {
    RenderRepaintBoundary boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }

  void onFilterTapped(ColorFilter newFilter) async {
    setState(() {
      filter = newFilter;
    });
  }

  Future<double> getImageWidth(double newHeight) async {
    ui.Codec codec = await ui.instantiateImageCodec(image);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    double originalWidth = frameInfo.image.width.toDouble();
    double originalHeight = frameInfo.image.height.toDouble();

    double aspectRatio = originalWidth / originalHeight;

    double newWidth = newHeight * aspectRatio;

    return newWidth;
  }

  Future<void> addText() async {
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
              hintText: 'Escribe aquí..',
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
              child: const Text('Añadir', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );

    if (submit == true) {
      setState(() {
        texts.add(
          TextInfo(
            text: textEditingController.text,
            left: 0,
            top: 0,
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.normal,
            fontSize: 20,
            textAlign: TextAlign.left,
            isSelected: true
          ),
        );
        textEditingController.clear();
        if (selectedText != null) {
          texts[selectedText!].isSelected = false;
        }
        selectedText = texts.length-1;
      });
    }
    textEditingController.clear();
  }

  void removeText() {
    int i = selectedText!;
    setState(() {
      selectedText = null;
      texts.removeAt(i);
    });
  }

  Future<void> editText() async {
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
              hintText: 'Escribe aquí..',
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
        texts[selectedText!].text = textEditingController.text;
        textEditingController.clear();
      });
    }
    else{
      setState(() {
        textEditingController.clear();
      });
    }
  }

  void biggerText() {
    setState(() {
      texts[selectedText!].fontSize = texts[selectedText!].fontSize+1;
    });
  }

  void smallerText() {
    setState(() {
      texts[selectedText!].fontSize = texts[selectedText!].fontSize-1;
    });
  }

  void boldText() {
    setState(() {
      if (texts[selectedText!].fontWeight == FontWeight.bold) {
        texts[selectedText!].fontWeight = FontWeight.normal;
      }
      else {
        texts[selectedText!].fontWeight = FontWeight.bold;
      }
    });
  }

  void italicText() {
    setState(() {
      if (texts[selectedText!].fontStyle == FontStyle.italic) {
        texts[selectedText!].fontStyle = FontStyle.normal;
      }
      else {
        texts[selectedText!].fontStyle = FontStyle.italic;
      }
    });
  }


  void changeImageColor(Color newColor) {
    setState(() {
      imageColor = newColor;
    });
  }

  void cleanImageColor() {
    setState(() {
      imageColor = null;
    });
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double spaceHeight = MediaQuery.of(context).size.height * 0.06;
    double appBarHeight = MediaQuery.of(context).size.height * 0.09;
    double screenWidth = MediaQuery.of(context).size.width;
    double imageHeight = MediaQuery.of(context).size.height * 0.55;
    bool changedWidth = false;

    if (isFirstTime) {
      final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        image = args?['image'];
        isFirstTime = false;
        imageWidth = getImageWidth(imageHeight);
      });
    }

    return FutureBuilder(
      future: imageWidth,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text("Se ha producido un error");
          } else if (snapshot.hasData) {

            if (snapshot.data! > screenWidth){
              double aspectRatio = imageHeight / snapshot.data!;
              imageHeight = screenWidth * aspectRatio;
              changedWidth = true;
            }

            List<Widget> textWidgets = texts.asMap().entries.map((entry) {
              int index = entry.key;
              var textInfo = entry.value;
              return Positioned(
                left: textInfo.left,
                top: textInfo.top,
                child: _selectedIndex == 1
                    ? Draggable(
                        feedback: ImageText(textInfo: textInfo),
                        child: ImageText(textInfo: textInfo),
                        onDragEnd: (drag) {
                          final renderBox = context.findRenderObject() as RenderBox;
                          Offset off = renderBox.globalToLocal(drag.offset);
                          double paddingLateral = MediaQuery.of(context).padding.left;
                          double paddingSuperior = MediaQuery.of(context).padding.top;
                          double spaceLateral = (screenWidth - snapshot.data!) / 2;
                          if (changedWidth) {
                            spaceLateral = 0;
                          }

                          setState(() {
                            textInfo.top = off.dy - appBarHeight - spaceHeight - paddingSuperior;
                            textInfo.left = off.dx - spaceLateral - paddingLateral;
                            textInfo.isSelected = true;
                            if (selectedText != null && selectedText != index) {
                              texts[selectedText!].isSelected = false;
                            }
                            selectedText = index;
                          });
                        },
                      )
                    : ImageText(textInfo: textInfo)
              );
            }).toList();

            return Scaffold(
              key: scaffoldKey,
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.white12,
              appBar: AppBar(
                toolbarHeight: appBarHeight,
                automaticallyImplyLeading: false,
                title: const Text('Editor'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    exit();
                  },
                ),
                actions: [
                  InkWell(
                      onTap: () async {
                        Uint8List? editedImage = await _applyFilterAndGetBytes();
                        if (editedImage != null) {
                          Navigator.of(scaffoldKey.currentContext!).push(
                            MaterialPageRoute(builder: (context) => CutImage(image: editedImage)),
                          );
                        }
                        else {
                          ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "Se ha producido un error");
                        }
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
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: spaceHeight),
                  SafeArea(
                      child: SizedBox(
                        height: imageHeight,
                        width: changedWidth ? screenWidth : snapshot.data!,
                        child: RepaintBoundary(
                            key: _globalKey,
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (selectedText != null) {
                                      setState(() {
                                        texts[selectedText!].isSelected = false;
                                        selectedText = null;
                                      });
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      ColorFiltered(
                                          colorFilter: filter,
                                          child: Image.memory(image, fit: BoxFit.fitHeight)
                                      ),
                                      Container(
                                        color: imageColor,
                                        width: changedWidth ? screenWidth : snapshot.data!,
                                        height: imageHeight,
                                      ),
                                    ],
                                  ),
                                ),
                                ...textWidgets,
                              ],
                            )
                        ),
                      )
                  ),
                  const Spacer(),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      height: 70,
                      child: _editOptions().elementAt(_selectedIndex)
                  )
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                unselectedItemColor: Colors.white,
                selectedIconTheme: const IconThemeData(
                    color: Colors.deepOrange,
                    size: 40
                ),
                unselectedIconTheme: const IconThemeData(
                    color: Colors.white,
                    size: 30
                ),
                backgroundColor: Colors.black87,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.filter),
                    label: 'Filtros',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.textsms_outlined),
                    label: 'Texto',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.color_lens_outlined),
                    label: 'Ajustar color',
                  ),
                ],
                currentIndex: _selectedIndex,
                onTap: _onNavigationItemTapped,
              ),
            );
          } else {
            return const Text("ERROR");
          }
        } else {
          return Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: const Center(child: CircularProgressIndicator(color: Colors.deepOrange),),
          );
        }
      },
    );

  }
}







