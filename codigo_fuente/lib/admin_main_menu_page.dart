import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AdminMainMenuPage extends StatefulWidget {
  const AdminMainMenuPage({super.key});

  @override
  State<AdminMainMenuPage> createState() => _AdminMainMenuPageState();
}

class _AdminMainMenuPageState extends State<AdminMainMenuPage>
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
      appBar: AppBar(title: Text("Menú administrador")),
      body: Column(children: [Text("Añade widgets aqui")]),
    );
  }
}
