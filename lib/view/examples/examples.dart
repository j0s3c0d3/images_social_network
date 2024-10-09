import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tfg_project/controller/examples/examples_controller.dart';
import 'package:tfg_project/util/order_enum.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tfg_project/view/examples/example_detail.dart';

import '../../model/example_model.dart';

class ExamplesPage extends StatefulWidget {
  const ExamplesPage({super.key});

  @override
  _ExamplesPageState createState() => _ExamplesPageState();
}

class _ExamplesPageState extends State<ExamplesPage> {

  final ExamplesController controller = ExamplesController();
  late Future<List<Example>?> examples;

  late Order order;

  Future<List<Example>?> future() async {
    return await controller.getExamples(order);
  }

  @override
  void initState() {
    order = Order.latest;
    examples = future();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: Row(
          children: [
            Expanded(child: GestureDetector(
              onTap: () {
                setState(() {
                  order = Order.latest;
                  examples = future();
                });
              },
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: order == Order.latest ? Colors.white : Colors.black,
                    border: Border.all(
                      color: order == Order.latest ? Colors.black : Colors.white,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Center(
                    child: Text(
                      OrderExtension.getOrderViewName(Order.latest),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: order == Order.latest ? Colors.deepOrange : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
              ),
            )),
            Expanded(child: GestureDetector(
              onTap: () {
                setState(() {
                  order = Order.oldest;
                  examples = future();
                });
              },
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: order == Order.oldest ? Colors.white : Colors.black,
                    border: Border.all(
                      color: order == Order.oldest ? Colors.black : Colors.white,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Center(
                    child: Text(
                      OrderExtension.getOrderViewName(Order.oldest),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: order == Order.oldest ? Colors.deepOrange : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
              ),
            )),
            Expanded(child: GestureDetector(
              onTap: () {
                setState(() {
                  order = Order.popular;
                  examples = future();
                });
              },
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: order == Order.popular ? Colors.white : Colors.black,
                    border: Border.all(
                      color: order == Order.popular ? Colors.black : Colors.white,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Center(
                    child: Text(
                      OrderExtension.getOrderViewName(Order.popular),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: order == Order.popular ? Colors.deepOrange : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
              ),
            )),
            Expanded(child: GestureDetector(
              onTap: () {
                setState(() {
                  order = Order.random;
                  examples = future();
                });
              },
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: order == Order.random ? Colors.white : Colors.black,
                    border: Border.all(
                      color: order == Order.random ? Colors.black : Colors.white,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Center(
                    child: Text(
                      OrderExtension.getOrderViewName(Order.random),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: order == Order.random ? Colors.deepOrange : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
              ),
            )),
          ],
        ),),
        const SizedBox(height: 5,),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Divider(height: 2, thickness: 2, color: Colors.deepOrangeAccent,),),
        FutureBuilder(
            future: examples,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Expanded(child: Center(
                    child: Text(
                      "Se ha producido un error",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),);
                }
                else if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return const Expanded(child: Center(
                      child: Text(
                        "No se encuentran resultados",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),);
                  }
                  else {
                    return Expanded(child: Padding(
                      padding: const EdgeInsets.only(left: 7, right: 7, bottom: 3),
                      child: GridView.custom(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverQuiltedGridDelegate(
                            crossAxisCount: 4,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            pattern: [
                              const QuiltedGridTile(2, 2),
                              const QuiltedGridTile(1, 1),
                              const QuiltedGridTile(1, 1),
                              const QuiltedGridTile(1, 2),
                            ]
                        ),
                        childrenDelegate: SliverChildBuilderDelegate(
                            childCount: snapshot.data!.length,
                                (context, index) {
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => ExampleDetail(example: snapshot.data![index])),
                                    );
                                  },
                                  child: Hero(
                                    tag: snapshot.data![index].id!,
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data![index].urlSmall!,
                                      imageBuilder: (ctx, img) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              image: DecorationImage(image: img, fit: BoxFit.cover)
                                          ),
                                        );
                                      },
                                    ),
                                  )
                              );
                            }),
                      ),
                    ));
                  }
                }
                else {
                  return const Expanded(child: Center(
                    child: Text(
                      "No se encuentran resultados",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),);
                }
              }
              else {
                return const Expanded(child: Center(
                  child: CircularProgressIndicator(color: Colors.deepOrange),
                ),);
              }
            }
        )
      ],
    );
  }
}


