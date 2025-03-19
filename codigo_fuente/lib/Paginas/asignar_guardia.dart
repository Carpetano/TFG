import 'package:flutter/material.dart';

class AsignarGuardia extends StatefulWidget {
  const AsignarGuardia({super.key});

  @override
  State<AsignarGuardia> createState() => _AsignarGuardiaState();
}

class _AsignarGuardiaState extends State<AsignarGuardia> {
  int? selectedRow; // Fila seleccionada
  List<List<List<TextEditingController>>> controllers =
      []; // Controladores para cada celda

  Future<void> claimGuardia() async {}

  @override
  void initState() {
    super.initState();
    // Inicializar controladores (8 filas x 7 sesiones x 3 columnas)
    for (int i = 0; i < 8; i++) {
      List<List<TextEditingController>> rowControllers = [];
      for (int j = 0; j < 7; j++) {
        List<TextEditingController> sessionControllers = [];
        for (int k = 0; k < 3; k++) {
          sessionControllers.add(TextEditingController());
        }
        rowControllers.add(sessionControllers);
      }
      controllers.add(rowControllers);
    }
  }

  @override
  void dispose() {
    // Liberar controladores al cerrar la pantalla
    for (var row in controllers) {
      for (var session in row) {
        for (var controller in session) {
          controller.dispose();
        }
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
              child: SizedBox(
                width: MediaQuery.of(context).size.width, // Ocupa todo el ancho
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        Colors.blueAccent.withOpacity(0.3),
                      ),
                      columns: const [
                        DataColumn(label: Text('Sesión 1')),
                        DataColumn(label: Text('Sesión 2')),
                        DataColumn(label: Text('Sesión 3')),
                        DataColumn(label: Text('Recreo')),
                        DataColumn(label: Text('Sesión 4')),
                        DataColumn(label: Text('Sesión 5')),
                        DataColumn(label: Text('Sesión 6')),
                      ],
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
                              SizedBox(
                                width: 200, // Ancho fijo para cada celda
                                height: 150, // Altura fija para cada celda
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller:
                                            controllers[rowIndex][colIndex][0],
                                        decoration: const InputDecoration(
                                          labelText: 'Profesor',
                                          border: OutlineInputBorder(),
                                        ),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 5),
                                      TextField(
                                        controller:
                                            controllers[rowIndex][colIndex][1],
                                        decoration: const InputDecoration(
                                          labelText: 'Asignación',
                                          border: OutlineInputBorder(),
                                        ),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 5),
                                      TextField(
                                        controller:
                                            controllers[rowIndex][colIndex][2],
                                        decoration: const InputDecoration(
                                          labelText: 'Comentarios',
                                          border: OutlineInputBorder(),
                                        ),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
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
                        for (var session in controllers[selectedRow!]) {
                          for (var controller in session) {
                            controller.clear();
                          }
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