import 'package:codigo/add_ausencia_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Import the slidable package

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

  void gotoAddAusencia() {
    print("Navigating to Adding ausencia page");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAusenciaPage()),
    );
  }

  // Example function for actions when sliding
  void showSlideAction() {
    print("Slidable action triggered");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menú profesor")),
      body: Column(
        children: [
          // First Slidable Row (contains 'Añadir Ausencia' action)
          Slidable(
            // Action when swiped from the start (left)
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => showSlideAction(),
                  backgroundColor: Colors.green,
                  icon: Icons.add,
                  label: 'Añadir',
                ),
              ],
            ),
            // Action when swiped from the end (right)
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => showSlideAction(),
                  backgroundColor: Colors.blue,
                  icon: Icons.info,
                  label: 'Info',
                ),
                SlidableAction(
                  onPressed: (context) => showSlideAction(),
                  backgroundColor: Colors.red,
                  icon: Icons.delete,
                  label: 'Eliminar',
                ),
              ],
            ),
            // Child is a simple Row with Text
            child: ListTile(
              title: Text("Añadir Ausencia"),
              onTap: gotoAddAusencia, // Trigger navigation on tap
            ),
          ),
          SizedBox(height: 10),
          // Second Slidable Row (contains another 'Añadir Ausencia' action)
          Slidable(
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => showSlideAction(),
                  backgroundColor: Colors.green,
                  icon: Icons.add,
                  label: 'Añadir',
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => showSlideAction(),
                  backgroundColor: Colors.blue,
                  icon: Icons.info,
                  label: 'Info',
                ),
                SlidableAction(
                  onPressed: (context) => showSlideAction(),
                  backgroundColor: Colors.red,
                  icon: Icons.delete,
                  label: 'Eliminar',
                ),
              ],
            ),
            child: ListTile(
              title: Text("Añadir Ausencia"),
              onTap: gotoAddAusencia,
            ),
          ),
          SizedBox(height: 20),
          // The button to "Add new Ausencia"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: gotoAddAusencia, // Trigger the same navigation
              child: Text("Añadir Nueva Ausencia"),
            ),
          ),
        ],
      ),
    );
  }
}
