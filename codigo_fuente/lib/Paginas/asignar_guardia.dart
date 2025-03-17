import 'package:flutter/material.dart';

class AsignarGuardia extends StatefulWidget {
  const AsignarGuardia({super.key});

  @override
  State<AsignarGuardia> createState() => _AsignarGuardiaState();
}

class _AsignarGuardiaState extends State<AsignarGuardia> {
  int? selectedRow; // Fila seleccionada
  List<List<TextEditingController>> controllers =
      []; // Controladores para cada celda

  @override
  void initState() {
    super.initState();
    // Inicializar controladores (8 filas x 7 sesiones por ejemplo)
    for (int i = 0; i < 8; i++) {
      List<TextEditingController> rowControllers = [];
      for (int j = 0; j < 7; j++) {
        rowControllers.add(TextEditingController());
      }
      controllers.add(rowControllers);
    }
  }

  @override
  void dispose() {
    // Liberar controladores al cerrar la pantalla
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profesor: {Nombre}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        actions: const [
          Icon(Icons.account_circle, size: 30, color: Colors.white),
          SizedBox(width: 10),
        ],
      ),
      body: Container(
        color: Colors.white, // Fondo blanco como todas las pantallas
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Asignar Guardia',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Center(
                  // Aquí agregamos el Center para centrar la tabla
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Colors.blueAccent.withOpacity(0.3),
                    ),
                    columns: List.generate(
                      7,
                      (index) => DataColumn(label: Text('Sesión ${index + 1}')),
                    ),
                    rows: List.generate(8, (rowIndex) {
                      return DataRow(
                        selected: selectedRow == rowIndex,
                        onSelectChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              selectedRow = rowIndex;
                            } else {
                              selectedRow = null;
                            }
                          });
                        },
                        cells: List.generate(7, (colIndex) {
                          return DataCell(
                            TextField(
                              controller: controllers[rowIndex][colIndex],
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontSize: 14),
                              enabled: true,
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ),
            if (selectedRow != null) // Solo aparece si hay fila seleccionada
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Acciones al coger guardia
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Guardia asignada correctamente"),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Coger guardia"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Limpiar datos de la fila seleccionada
                        for (var controller in controllers[selectedRow!]) {
                          controller.clear();
                        }
                        setState(() {
                          selectedRow = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Guardia anulada")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Anular guardia"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Vuelve a pantalla anterior
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Volver"),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
