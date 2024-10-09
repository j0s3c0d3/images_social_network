import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:tfg_project/view/profile/update_password.dart';

import '../../controller/profile/account_controller.dart';
import '../../model/user_model.dart';
import '../../util/date_formats.dart';
import '../../util/snack_bar.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  late User user;
  late String email;
  late DateTime birthDate;
  bool _isLoading = false;

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final controller = AccountController();
  final birthDateController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();

  Future<void> submit() async {
    final form = formKey.currentState;
    bool? submit = true;

    if (form!.validate()) {
      if (email != user.email) {
        submit = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text('Necesitarás verificar tu nuevo email para poder acceder con él a tu cuenta. ¿Deseas continuar?'),
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
        setState(() {
          _isLoading = true;
        });
        form.save();

        try {
          bool success = await controller.updateAccount(email, birthDate);
          setState(() {
            _isLoading = false;
          });
          if (success) {
            if (email != user.email) {
              Navigator.pushReplacementNamed(scaffoldKey.currentContext!, '/login',);
            }
            else {
              setState(() {
                user = context.read<UserModel>().user!;
                birthDate = user.birthDate!;
                birthDateController.text = DateFormats.format(birthDate);
              });
              ShowSnackBar.showSnackBar(
                  scaffoldKey.currentContext!, "Se han actualizado los datos de tu cuenta");
            }
          }
          else {
            ShowSnackBar.showSnackBar(
                scaffoldKey.currentContext!, "Se ha producido un error");
          }
        }
        catch (e) {
          setState(() {
            _isLoading = false;
          });
          ShowSnackBar.showSnackBar(
              scaffoldKey.currentContext!, "Se ha producido un error");
        }
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: scaffoldKey.currentContext!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != birthDate) {
      final formattedDate = DateFormats.truncateTime(picked);
      birthDateController.text = DateFormats.format(formattedDate);
      setState(() {
        birthDate = formattedDate;
      });
    }
  }

  Future<void> deleteAccount() async {
    bool? submit = await showDialog<bool>(
      context: scaffoldKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Verifica tu contraeña"),
          content: TextField(
            controller: textEditingController,
            obscureText: true,
            decoration: const InputDecoration(
              suffixIcon: Icon(
                Icons.edit,
              ),
              hintText: 'Introduce tu contraseña actual',
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
      setState(() {
        _isLoading = true;
      });
      bool correctPassword = await controller.checkPassword(textEditingController.text);
      if (correctPassword) {
        bool? submit2 = await showDialog<bool>(
          context: scaffoldKey.currentContext!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text('Estás seguro de que quieres eliminar tu cuenta? Esta acción es irreversible'),
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
                  child: const Text('Eliminar', style: TextStyle(color: Colors.white),),
                ),
              ],
            );
          },
        );
        if (submit2 == true) {
          bool success = await controller.deleteAccount();
          setState(() {
            _isLoading = false;
          });
          if (success) {
            Navigator.pushReplacementNamed(scaffoldKey.currentContext!, '/login',);
          }
          else {
            ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "Se ha producido un error");
          }
        }
        else {
          setState(() {
            _isLoading = false;
          });
        }
      }
      else {
        setState(() {
          _isLoading = false;
        });
        ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "La contraseña introducida es incorrecta");
      }
    }
    setState(() {
      textEditingController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    user = context.read<UserModel>().user!;
    email = user.email!;
    birthDate = user.birthDate!;
    birthDateController.text = DateFormats.format(birthDate);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          automaticallyImplyLeading: false,
          title: const Text('Cuenta'),
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
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
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
                            onChanged: (val) {
                              setState(() => email = val);
                            },
                            initialValue: user.email!,
                            decoration: const InputDecoration(labelText: "Email"),
                          ),
                          const SizedBox(height: 15,),
                          TextFormField(
                            readOnly: true,
                            controller: birthDateController,
                            onTap: () => _selectDate(),
                            decoration: const InputDecoration(
                              labelText: 'Fecha de nacimiento',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                          const SizedBox(height: 20,),
                          ElevatedButton(
                              onPressed: () {
                                if (email != user.email ||
                                    !(birthDate.year == user.birthDate?.year &&
                                    birthDate.month == user.birthDate?.month &&
                                    birthDate.day == user.birthDate?.day)) {
                                  submit();
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                  if (email != user.email ||
                                      !(birthDate.year == user.birthDate?.year &&
                                      birthDate.month == user.birthDate?.month &&
                                      birthDate.day == user.birthDate?.day)) {
                                    return null;
                                  } else {
                                    return Colors.grey;
                                  }
                                }),
                              ),
                              child: (email != user.email ||
                                  !(birthDate.year == user.birthDate?.year &&
                                  birthDate.month == user.birthDate?.month &&
                                  birthDate.day == user.birthDate?.day))
                                  ? const Text("Confirmar edición")
                                  : const Text("No se han realizado cambios")
                          ),
                        ],
                      )
                    ),
                  ),
                  const SizedBox(height: 30,),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const UpdatePasswordPage()),
                      ).then((result) {
                        if (result == true) {
                          ShowSnackBar.showSnackBar(
                              scaffoldKey.currentContext!, "Se ha actualizado tu contraseña");
                        }
                      });
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Si desea cambiar tu contraseña ", style: TextStyle(fontSize: 15),),
                        Text(
                          "pulsa aquí",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.deepOrange,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  GestureDetector(
                    onTap: () {
                      deleteAccount();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("También puedes ", style: TextStyle(fontSize: 15),),
                        Text(
                          "eliminar tu cuenta",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.deepOrange,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}