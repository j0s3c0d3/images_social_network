import 'package:flutter/material.dart';
import 'package:tfg_project/controller/feed/feed_controller.dart';
import 'package:tfg_project/model/image_model.dart' as model;

import '../common/feed_list.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, required this.scaffoldKey});

  final GlobalKey<ScaffoldMessengerState> scaffoldKey;

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  final controller = FeedController();

  late Future<List<model.ImageWithUser>?> images;
  List<bool> _isSelected = [true, false];
  int minLikes = 0;

  Future<List<model.ImageWithUser>?> future() async {
    return controller.getFeedImages(0);
  }

  @override
  void initState() {
    images = future();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FeedPage oldWidget) {
    setState(() {
      if (_isSelected.first) {
        images = controller.getFeedImages(minLikes);
      }
      else {
        images = controller.getAllImages(minLikes);
      }
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ToggleButtons(
              isSelected: _isSelected,
              onPressed: (int index) {
                setState(() {
                  _isSelected = List.generate(_isSelected.length, (i) => i == index);
                });
                if (index == 0) {
                  setState(() {
                    images = controller.getFeedImages(minLikes);
                  });
                }
                else {
                  setState(() {
                    images = controller.getAllImages(minLikes);
                  });
                }
              },
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  child: const Text("Seguidos", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0
                  ),),
                ),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  child: const Text("Explorar", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0
                  ),),
                ),
              ],
            ),
            SizedBox(
              width: 100,
              height: 40,
              child: TextField(
                decoration: const InputDecoration(hintText: "MG min"),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {
                    minLikes = int.tryParse(val) ?? 0;
                    if (_isSelected.first) {
                      images = controller.getFeedImages(minLikes);
                    }
                    else {
                      images = controller.getAllImages(minLikes);
                    }
                  });
                },
              ),
            )
          ],
        ),
        const SizedBox(height: 4.0,),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Divider(thickness: 2.0, color: Colors.deepOrangeAccent,),),
        FutureBuilder(
            future: images,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Text("Se ha producido un error");
                } else if (snapshot.hasData) {
                  if (snapshot.data == null) {
                    return const Text("Se ha producido un error");
                  }
                  else {
                    final feedImages = snapshot.data;
                    if (feedImages!.isEmpty){
                      return const Expanded(child: Center(child:
                        Padding(padding: EdgeInsets.all(15),
                          child: Text("Ninguna de las personas a las que sigues ha publicado nada",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),),)));
                    }
                    else {
                      return Expanded(child: FeedList(feedImages: feedImages, scaffoldKey: widget.scaffoldKey, controller: controller, isEditing: false,));
                    }
                  }
                } else {
                  return const Text("Se ha producido un error");
                }
              } else {
                return Expanded(child: Container(
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: const Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
                ));
              }
            }
        )
      ],
    );
  }
}
