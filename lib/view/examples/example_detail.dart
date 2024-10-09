import 'package:flutter/material.dart';
import 'package:tfg_project/model/example_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../util/date_formats.dart';

class ExampleDetail extends StatelessWidget {
  const ExampleDetail({super.key, required this.example});

  final Example example;

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white12,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
        title: const Text('Detalles'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8,),
            Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormats.format(DateTime.parse(example.createdAt!)),
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: example.urlBig!,
                        placeholder: (context, url) => SizedBox(
                          width: double.infinity,
                          height: screenWidth,
                          child: const Center(child: CircularProgressIndicator(),),
                        ),
                        errorWidget: (context, url, error) => SizedBox(
                          width: double.infinity,
                          height: screenWidth,
                          child: const Center(child: Icon(Icons.error_outline_outlined, size: 50,),),
                        ),
                        imageBuilder: (ctx, img) {
                          return Image(
                              width: double.infinity,
                              fit: BoxFit.cover,
                              image: img
                          );
                        },
                      )
                  ),
                  if (example.description != null)
                    Column(
                      children: [
                        const SizedBox(height: 10.0),
                        Text(
                          example.description!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    )
                ],
              ),
            ),
            const SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }
}