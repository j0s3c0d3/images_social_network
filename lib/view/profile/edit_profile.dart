import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tfg_project/model/user_model.dart';
import 'package:tfg_project/view/common/cirular_image.dart';
import 'package:provider/provider.dart';

import '../../controller/profile/edit_profile_controller.dart';
import '../../util/snack_bar.dart';


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final controller = EditProfileController();

  late User user;
  late String userName;
  bool _isLoading = false;
  Uint8List? newImage;

  Future<void> submit() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      setState(() {
        _isLoading = true;
      });
      form.save();

      try {
        bool success = await controller.editProfile(userName, newImage);
        setState(() {
          _isLoading = false;
        });
        if (success) {
          Navigator.pushReplacementNamed(
            scaffoldKey.currentContext!,
            '/home',
            arguments: {'selectedIndex': 3},
          );
        }
        else {
          ShowSnackBar.showSnackBar(scaffoldKey.currentContext!, "Se ha producido un error");
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

  @override
  void initState() {
    super.initState();
    user = context.read<UserModel>().user!;
    userName = user.userName;
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
          title: const Text('Editar Perfil'),
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
                CircularImage(
                  isEditable: true,
                  image: user.profileImage,
                  scaffoldKey: scaffoldKey,
                  isSmall: false,
                  onImageChanged: (image) {
                    setState(() {
                      newImage = image;
                    });
                  },
                ),
                const SizedBox(height: 20,),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
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
                              onChanged: (val) {
                                setState(() => userName = val);
                              },
                              initialValue: user.userName,
                              decoration: const InputDecoration(labelText: "Username"),
                            ),
                            const SizedBox(height: 20,),
                            ElevatedButton(
                                onPressed: () {
                                  if (newImage != null || userName != user.userName) submit();
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                    if (newImage != null || userName != user.userName) {
                                      return null;
                                    } else {
                                      return Colors.grey;
                                    }
                                  }),
                                ),
                                child: (newImage != null || userName != user.userName)
                                    ? const Text("Confirmar edición")
                                    : const Text("No se han realizado cambios")
                            ),
                          ],
                        )
                      ),
                    ),
                  ]
                ),
              ],
            )
    );
  }
}