import 'package:flutter/material.dart';

class AnadirBaja extends StatefulWidget {
  const AnadirBaja({Key? key}) : super(key: key);

  @override
  State<AnadirBaja> createState() => _AnadirBajaState();
}

class _AnadirBajaState extends State<AnadirBaja> {
  final TextEditingController motivoController = TextEditingController();
  final TextEditingController comentarioController = TextEditingController();

  List<String> horas = [
    'Primera hora',
    'Segunda hora',
    'Tercera hora',
    'Recreo', // Añadido el recreo
    'Cuarta hora',
    'Quinta hora',
    'Sexta hora',
  ];
  List<String> horasSeleccionadas = [];
  bool todoElDia = false;

  void guardarBaja() {
    // Aquí iría la lógica para guardar la baja (por ejemplo, enviarla a la base de datos)
    print('Horas seleccionadas: ${todoElDia ? "Todo el día" : horasSeleccionadas.join(", ")}');
    print('Motivo: ${motivoController.text}');
    print('Comentario: ${comentarioController.text}');
    Navigator.pop(context); // Volver atrás tras guardar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Baja')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Selecciona las horas:', style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: const Text('Todo el día'),
              value: todoElDia,
              onChanged: (value) {
                setState(() {
                  todoElDia = value!;
                  if (todoElDia) {
                    horasSeleccionadas = List.from(horas);
                  } else {
                    horasSeleccionadas.clear();
                  }
                });
              },
            ),
            if (!todoElDia)
              ...horas.map((hora) => CheckboxListTile(
                    title: Text(hora),
                    value: horasSeleccionadas.contains(hora),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          horasSeleccionadas.add(hora);
                        } else {
                          horasSeleccionadas.remove(hora);
                        }
                      });
                    },
                  )),
            const SizedBox(height: 20),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo de la falta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: comentarioController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Comentarios (tarea, detalles, etc.)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                onPressed: guardarBaja,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Color de fondo más visible
                    foregroundColor: Colors.white, // Color del texto
                ),
                child: const Text('Guardar Baja'),
                ),

                ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Color gris
                    foregroundColor: Colors.white, // Color del texto
                ),
                child: const Text('Volver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
