import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfesorMainMenuPage extends StatefulWidget {
  const ProfesorMainMenuPage({super.key});

  @override
  State<ProfesorMainMenuPage> createState() => _ProfesorMainMenuPageState();
}

class _ProfesorMainMenuPageState extends State<ProfesorMainMenuPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menú profesor")),
      body: Column(children: [Text("Añade widgets aqui")]),
    );
  }
}
