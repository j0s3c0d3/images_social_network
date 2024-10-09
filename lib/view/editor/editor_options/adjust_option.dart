import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

class AdjustOption extends StatefulWidget {
  const AdjustOption({super.key, required this.onAdd, required this.onRemove, required this.image, required this.currentColor});

  final Function() onRemove;
  final Function(Color color) onAdd;
  final Uint8List image;
  final Color? currentColor;

  @override
  _AdjustOptionState createState() => _AdjustOptionState();
}

class _AdjustOptionState extends State<AdjustOption> {

  List<Color> buttonColors = [
    Colors.white,
    Colors.white,
  ];

  void _changeButtonColor(Color color, int index) {
    setState(() {
      buttonColors[index] = color;
    });
  }

  Future<void> onAdd() async {
    final Color? selectedColor = await Navigator.of(context).push<Color>(
      MaterialPageRoute(
        builder: (BuildContext context) {
          Color? newColor = widget.currentColor;

          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            floatingActionButton: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.deepOrangeAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.format_color_fill_outlined),
                iconSize: 35,
                onPressed: () {
                  Navigator.of(context).pop(newColor);
                },
                color: Colors.white,
              ),
            ),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Ajustar color'),
              leading: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: ColorPicker(
                color: newColor ?? Colors.transparent,
                onChanged: (Color value) {
                  newColor = value;
                },
              ),
            )
          );
        },
      ),
    );

    if (selectedColor != null) {
      widget.onAdd(selectedColor);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            widget.onRemove();
          },
          onTapDown: (_) => _changeButtonColor(Colors.deepOrange, 0),
          onTapUp: (_) => _changeButtonColor(Colors.white, 0),
          onTapCancel: () => _changeButtonColor(Colors.white, 0),
          child: Container(
            margin: const EdgeInsets.all(10),
            width: 75,
            decoration: BoxDecoration(
              color: buttonColors[0],
              border: Border.all(
                color: Colors.deepOrange,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Center(
                child: Text("Limpiar",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                )
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onAdd();
          },
          onTapDown: (_) => _changeButtonColor(Colors.deepOrange, 1),
          onTapUp: (_) => _changeButtonColor(Colors.white, 1),
          onTapCancel: () => _changeButtonColor(Colors.white, 1),
          child: Container(
            margin: const EdgeInsets.all(10),
            width: 75,
            decoration: BoxDecoration(
              color: buttonColors[1],
              border: Border.all(
                color: Colors.deepOrange,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Center(
                child: Text("Ajustar",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                )
            ),
          ),
        ),
      ],
    );
  }
}