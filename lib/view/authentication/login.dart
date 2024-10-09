import 'package:flutter/material.dart';
import 'package:tfg_project/controller/authentication/login_controller.dart';
import 'package:tfg_project/view/authentication/sign_up.dart';
import 'package:get/get.dart';

import '../../util/snack_bar.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _isLoading = false;
  String? email;
  String? password;

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final controller = LoginController();

  Future<void> submit() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();
      setState(() => _isLoading = true);

      try {
        bool success = await controller.login(email!, password!);
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pushReplacementNamed(scaffoldKey.currentContext!, '/home');
        }
        else {
          ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "Usuario o contraseña incorrectos");
        }
      }
      catch(e) {
        setState(() => _isLoading = false);
        ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "Usuario o contraseña incorrectos");
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Inicia sesión'),
      ),
      body: _isLoading
          ? Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white,
              child: const Center(child: CircularProgressIndicator(color: Colors.deepOrange),),
            )
          : Center(
              child: SingleChildScrollView(
                child:  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10, top: 15),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Introduzca su email';
                                }
                                if (!val.isEmail) {
                                  return 'La dirección de email es incorrecta';
                                }
                                return null;
                              },
                              onSaved: (val) {
                                email = val;
                              },
                              decoration: const InputDecoration(labelText: "Email"),
                            ),
                            const SizedBox(height: 15,),
                            TextFormField(
                              obscureText: true,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Introduzca la contraseña';
                                }
                                return null;
                              },
                              onSaved: (val) {
                                password = val;
                              },
                              decoration: const InputDecoration(labelText: "Password"),
                            ),
                            const SizedBox(height: 20,),
                            ElevatedButton(
                              onPressed: () {
                                submit();
                              },
                              child: const Text("Iniciar Sesión"),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("No tienes una cuenta?"),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const SignUpPage()),
                              );
                            },
                            child: const Text("Créala ahora!")
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}