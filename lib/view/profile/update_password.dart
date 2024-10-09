import 'package:flutter/material.dart';
import 'package:tfg_project/controller/profile/update_password_controller.dart';
import 'package:get/get.dart';

import '../../util/snack_bar.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
}


class _UpdatePasswordPageState extends State<UpdatePasswordPage> {

  final initialFormKey = GlobalKey<FormState>();
  final finalFormKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final controller = UpdatePasswordController();
  
  bool _isLoading = false;
  String? password;
  String? newPassword;
  String? confirmNewPassword;

  Future<void> submitNewPassword() async {
    setState(() {
      _isLoading = true;
    });
    try {
      bool success = await controller.changePassword(newPassword!);
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(scaffoldKey.currentContext!, true);
      }
      else {
        ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "Se ha producido un error");
      }
    }
    catch(e) {
      setState(() => _isLoading = false);
      ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "Se ha producido un error");
    }
  }
  
  Future<void> _showNewPasswordDialog() async {
    bool? submit;

    submit = await showDialog<bool>(
      context: scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crear nueva contraseña'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Form(
                      key: finalFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            obscureText: true,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Introduzca su nueva contraseña';
                              }
                              if (val.isAlphabetOnly || val.isNumericOnly || val.length < 8) {
                                return 'La contraseña debe tener al menos 8 caracteres y tener números y letras';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              setState(() => newPassword = val);
                            },
                            decoration: const InputDecoration(labelText: "Nueva contraseña"),
                          ),
                          const SizedBox(height: 15,),
                          TextFormField(
                            obscureText: true,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Confirme su nueva contraseña';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              setState(() => confirmNewPassword = val);
                            },
                            decoration: const InputDecoration(labelText: "Confirmar contraseña"),
                          ),
                        ],
                      )
                  ),
                )
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final form = finalFormKey.currentState;
                if (form!.validate()) {
                  form.save();
                  if (newPassword != confirmNewPassword) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Las contraseñas no coinciden'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Aceptar'),
                            ),
                          ],
                        );
                      },
                    );                  }
                  else {
                    Navigator.of(context).pop(true);
                  }
                }
              },
              child: const Text('Confirmar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
    
    if (submit == true) {
      submitNewPassword();
    }
  }

  Future<void> checkPassword() async {
    final form = initialFormKey.currentState;
    
    if (form!.validate()) {
      form.save();
      setState(() => _isLoading = true);

      try {
        bool success = await controller.checkPassword(password!);
        setState(() => _isLoading = false);
        if (success) {
          _showNewPasswordDialog();
        }
        else {
          ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "La contraseña es incorrecta");
        }
      }
      catch(e) {
        setState(() => _isLoading = false);
        ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "Se ha producido un error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        automaticallyImplyLeading: false,
        title: const Text('Actualizar Contraseña'),
      ),
      body: _isLoading
          ? Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white,
              child: const Center(child: CircularProgressIndicator(color: Colors.deepOrange),),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Form(
                      key: initialFormKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            obscureText: true,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Introduzca su contraseña actual';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              setState(() => password = val);
                            },
                            decoration: const InputDecoration(labelText: "Introduzca su contraseña actual"),
                          ),
                          const SizedBox(height: 15,),

                          ElevatedButton(
                              onPressed: () {
                                checkPassword();
                              },
                              child: const Text("Confirmar")
                          ),
                        ],
                      )
                  ),
                ),
              ],
            )

      );
  }
}