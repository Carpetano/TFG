import 'package:flutter/material.dart';

class SalaMainMenuPage extends StatefulWidget {
  const SalaMainMenuPage({super.key});

  @override
  State<SalaMainMenuPage> createState() => _SalaMainMenuPageState();
}

class _SalaMainMenuPageState extends State<SalaMainMenuPage>
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
      appBar: AppBar(title: Text("Menú sala")),
      body: Column(children: [Text("Añade widgets aqui")]),
    );
  }
}
