import 'package:flutter/material.dart';
import 'package:tfg_project/controller/authentication/log_out_controller.dart';

import '../../util/snack_bar.dart';

class LogOutButton extends StatelessWidget {
  LogOutButton({super.key, required this.scaffoldKey});

  final GlobalKey<ScaffoldMessengerState> scaffoldKey;

  final LogOutController controller = LogOutController();

  logOut() async {
    bool? submit = await showDialog<bool>(
      context: scaffoldKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Estás seguro de que quieres cerrar sesión?', style: TextStyle(fontSize: 20),),
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
              child: const Text('Confirmar', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );

    if (submit == true) {
      bool success = await controller.logOut();
      if (success) {
        Navigator.pushReplacementNamed(scaffoldKey.currentContext!, '/login');
      }
      else {
        ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "Se ha producido un error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(7),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
              blurRadius: 6,
              color: Colors.black,
              spreadRadius: 2
          )
        ],
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: IconButton(
        iconSize: 30,
        onPressed: () {
          logOut();
        },
        icon: const Icon(Icons.logout_rounded),
      ),
    );
  }
}