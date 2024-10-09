
import 'package:flutter/material.dart';

import '../../util/snack_bar.dart';

class FollowButton extends StatefulWidget {
  const FollowButton({super.key, required this.scaffoldKey, required this.isSmall, required this.onButtonPressed, required this.isFollowing});

  final bool isSmall;
  final bool isFollowing;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
  final Future<bool> Function(bool) onButtonPressed;

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {

  late bool following;

  void handleButtonPressed() async {

    bool? submit = true;

    if (following) {
      submit = await showDialog<bool>(
        context: widget.scaffoldKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('Estás seguro de que quieras dejar de estar en la lista de amigos este usuario? Él aún podría estar en la tuya.', style: TextStyle(fontSize: 18),),
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
    }

    if (submit == true) {
      bool result = await widget.onButtonPressed(following);
      if (result) {
        setState(() {
          following = !following;
        });
        if (following) {
          ShowSnackBar.showSnackBar(
              widget.scaffoldKey.currentContext!, "Ahora apareces en la lista de amigos de este usuario");
        }
      }
      else {
        ShowSnackBar.showSnackBar(
            widget.scaffoldKey.currentContext!, "No se ha podido completar la petición");
      }
    }
  }

  @override
  void initState() {
    setState(() {
      following = widget.isFollowing;
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.isSmall ? 50 : 70,
      width: widget.isSmall ? 70 : 80,
      child: ElevatedButton(
        onPressed: () {
          handleButtonPressed();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            following ? Colors.deepOrangeAccent : null,
          ),
          shape: MaterialStateProperty.all<CircleBorder>(
            const CircleBorder(),
          ),
        ),

        child: following
            ? Icon(Icons.person_remove_alt_1_outlined, color: Colors.black, size: widget.isSmall
              ? 25
              : 32,)
            : Icon(Icons.person_add_alt, size: widget.isSmall
              ? 25
              : 32,)
      ),
    );
  }
}