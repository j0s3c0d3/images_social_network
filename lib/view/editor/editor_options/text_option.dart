
import 'package:flutter/material.dart';


class TextOption extends StatefulWidget {
  const TextOption({super.key, required this.onTextAdded, required this.isTextSelected,
    required this.onTextRemoved, required this.onTextEdited, required this.onTextBigger, required this.onTextSmaller,
    required this.onTextBold, required this.onTextItalic});

  final Function() onTextAdded;
  final bool isTextSelected;
  final Function() onTextRemoved;
  final Function() onTextEdited;
  final Function() onTextBigger;
  final Function() onTextSmaller;
  final Function() onTextBold;
  final Function() onTextItalic;

  @override
  _TextOptionState createState() => _TextOptionState();
}

class _TextOptionState extends State<TextOption> {

  Color _containerColor = Colors.white;
  bool isTextSelected = false;

  List<Color> buttonColors = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  void _changeColor(Color color) {
    setState(() {
      _containerColor = color;
    });
  }

  void _changeButtonColor(Color color, int index) {
    setState(() {
      buttonColors[index] = color;
    });
  }


  void addText() {
    widget.onTextAdded();
  }

  void removeText() {
    widget.onTextRemoved();
  }

  void editText() {
    widget.onTextEdited();
  }

  void smallerText() {
    widget.onTextSmaller();
  }

  void biggerText() {
    widget.onTextBigger();
  }

  void boldText() {
    widget.onTextBold();
  }

  void italicText() {
    widget.onTextItalic();
  }

  @override
  void initState() {
    isTextSelected = widget.isTextSelected;
    super.initState();
  }

  @override
  void didUpdateWidget(TextOption oldWidget) {
    if (oldWidget.isTextSelected != widget.isTextSelected) {
      setState(() {
        isTextSelected = widget.isTextSelected;
      });
    }
    super.didUpdateWidget(oldWidget);
  }


  @override
  Widget build(BuildContext context) {
    return isTextSelected
        ? ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: () {
                  removeText();
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
                    child: Icon(Icons.remove_circle_outline)
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  editText();
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
                      child: Icon(Icons.edit)
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  biggerText();
                },
                onTapDown: (_) => _changeButtonColor(Colors.deepOrange, 2),
                onTapUp: (_) => _changeButtonColor(Colors.white, 2),
                onTapCancel: () => _changeButtonColor(Colors.white, 2),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  width: 75,
                  decoration: BoxDecoration(
                    color: buttonColors[2],
                    border: Border.all(
                      color: Colors.deepOrange,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                      child: Icon(Icons.text_increase)
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  smallerText();
                },
                onTapDown: (_) => _changeButtonColor(Colors.deepOrange, 3),
                onTapUp: (_) => _changeButtonColor(Colors.white, 3),
                onTapCancel: () => _changeButtonColor(Colors.white, 3),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  width: 75,
                  decoration: BoxDecoration(
                    color: buttonColors[3],
                    border: Border.all(
                      color: Colors.deepOrange,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                      child: Icon(Icons.text_decrease)
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  boldText();
                },
                onTapDown: (_) => _changeButtonColor(Colors.deepOrange, 4),
                onTapUp: (_) => _changeButtonColor(Colors.white, 4),
                onTapCancel: () => _changeButtonColor(Colors.white, 4),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  width: 75,
                  decoration: BoxDecoration(
                    color: buttonColors[4],
                    border: Border.all(
                      color: Colors.deepOrange,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                      child: Icon(Icons.format_bold)
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  italicText();
                },
                onTapDown: (_) => _changeButtonColor(Colors.deepOrange, 5),
                onTapUp: (_) => _changeButtonColor(Colors.white, 5),
                onTapCancel: () => _changeButtonColor(Colors.white, 5),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  width: 75,
                  decoration: BoxDecoration(
                    color: buttonColors[5],
                    border: Border.all(
                      color: Colors.deepOrange,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                      child: Icon(Icons.format_italic)
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: GestureDetector(
              onTap: () {
                addText();
              },
              onTapDown: (_) => _changeColor(Colors.deepOrange),
              onTapUp: (_) => _changeColor(Colors.white),
              onTapCancel: () => _changeColor(Colors.white),
              child: Container(
                margin: const EdgeInsets.all(10),
                width: 75,
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
                    "Añadir",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}


class TextInfo {
  String text;
  double left;
  double top;
  Color color;
  FontWeight fontWeight;
  FontStyle fontStyle;
  double fontSize;
  TextAlign textAlign;
  bool isSelected;

  TextInfo({
    required this.text,
    required this.left,
    required this.top,
    required this.color,
    required this.fontWeight,
    required this.fontStyle,
    required this.fontSize,
    required this.textAlign,
    required this.isSelected
  });
}


class ImageText extends StatelessWidget {
  const ImageText({super.key, required this.textInfo,});

  final TextInfo textInfo;

  @override
  Widget build(BuildContext context) {
    return textInfo.isSelected
        ? Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.orange,
                width: 2.0,
              ),
            ),
            child: Text(
              textInfo.text,
              textAlign: textInfo.textAlign,
              style: TextStyle(
                fontSize: textInfo.fontSize,
                fontWeight: textInfo.fontWeight,
                fontStyle: textInfo.fontStyle,
                color: textInfo.color,
              ),
            ),
          )
        : Text(
            textInfo.text,
            textAlign: textInfo.textAlign,
            style: TextStyle(
              fontSize: textInfo.fontSize,
              fontWeight: textInfo.fontWeight,
              fontStyle: textInfo.fontStyle,
              color: textInfo.color,
            ),
          );
  }
}