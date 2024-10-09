import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tfg_project/controller/authentication/sign_up_controller.dart';
import 'package:tfg_project/util/date_formats.dart';
import 'package:tfg_project/view/common/cirular_image.dart';
import 'package:get/get.dart';

import '../../util/snack_bar.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  bool _isLoading = false;
  String? email;
  String? password;
  String? confirmPassword;
  String? userName;
  DateTime? birthDate;
  Uint8List? profileImage;

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final controller = SignUpController();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: scaffoldKey.currentContext!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != birthDate) {
      setState(() {
        birthDate = DateFormats.truncateTime(picked);
      });
    }
  }

  Future<void> submit() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();
      if (password != confirmPassword) {
        ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "Las contraseñas no coinciden");
      }
      else {
        setState(() => _isLoading = true);

        try {
          if (profileImage != null && profileImage!.isEmpty) profileImage = null;
          bool success = await controller.signUp(email!, password!, userName!, profileImage, birthDate!);
          setState(() => _isLoading = false);
          if (success) {
            Navigator.pushReplacementNamed(scaffoldKey.currentContext!, '/home');
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
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Crea tu cuenta'),
        ),
        body: _isLoading
            ? Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.white,
                child: const Center(child: CircularProgressIndicator(color: Colors.deepOrange),),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircularImage(
                      isEditable: true,
                      image: null,
                      scaffoldKey: scaffoldKey,
                      isSmall: false,
                      onImageChanged: (image) {
                        setState(() {
                          profileImage = image;
                        });
                      },
                    ),
                    const SizedBox(height: 20,),
                    Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Introduzca el nombre de usuario';
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  setState(() => userName = val);
                                },
                                decoration: const InputDecoration(labelText: "Username"),
                              ),
                              const SizedBox(height: 15,),
                              TextFormField(
                                obscureText: true,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Introduzca la contraseña';
                                  }
                                  if (val.isAlphabetOnly || val.isNumericOnly || val.length < 8) {
                                    return 'La contraseña debe tener al menos 8 caracteres y tener números y letras';
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  setState(() => password = val);
                                },
                                decoration: const InputDecoration(labelText: "Password"),
                              ),
                              const SizedBox(height: 15,),
                              TextFormField(
                                obscureText: true,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Confirme la contraseña';
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  setState(() => confirmPassword = val);
                                },
                                decoration: const InputDecoration(labelText: "Confirm password"),
                              ),
                              const SizedBox(height: 15,),
                              TextFormField(
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Introduzca el email';
                                  }
                                  if (!val.isEmail) {
                                    return 'La dirección de email es incorrecta';
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  setState(() => email = val);
                                },
                                decoration: const InputDecoration(labelText: "Email"),
                              ),
                              const SizedBox(height: 15,),
                              TextFormField(
                                readOnly: true,
                                onTap: () => _selectDate(),
                                decoration: InputDecoration(
                                  labelText: 'Fecha de nacimiento',
                                  hintText: birthDate == null ? 'Introduce tu fecha de nacimiento' : DateFormats.format(birthDate!),
                                  prefixIcon: const Icon(Icons.calendar_today),
                                ),
                                validator: (val) {
                                  if (birthDate == null) {
                                    return 'Introduce tu fecha de nacimiento';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20,),
                              ElevatedButton(
                                  onPressed: () {
                                    submit();
                                  },
                                  child: const Text("Sign up")
                              ),
                            ],
                          )
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Ya tienes una cuenta de usuario?"),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Inicia Sesión!")
                        )
                      ],
                    )
                  ],
                ),
              )
    );
  }
}