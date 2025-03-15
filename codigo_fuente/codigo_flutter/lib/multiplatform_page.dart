import 'package:flutter/material.dart';

class MultiplatformPage extends StatelessWidget {
  const MultiplatformPage({super.key});

  @override
  Widget build(BuildContext context) {
    double SCREEN_WIDTH = MediaQuery.of(context).size.width;
    double SCREEN_HEIGHT = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title: const Text("Multiplatform page"),
        ),

        body: Container(
          color: Colors.black,
          // BACKGROUND COLOR = BLACK
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          child: Text(
            "Screen size: Width = ${SCREEN_WIDTH.toString()} , Height = ${SCREEN_HEIGHT.toString()}",
            style: TextStyle(
              color: Colors.white,
            ), // Make the text color white to contrast with the black background
          ),
        ),
      ),
    );
  }
}
