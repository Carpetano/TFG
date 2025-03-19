import 'package:flutter/material.dart';

class MisGuardias extends StatefulWidget {
  const MisGuardias({Key? key}) : super(key: key);

  @override
  State<MisGuardias> createState() => _MisGuardiasState();
}

class _MisGuardiasState extends State<MisGuardias> {
  List<String> guardiasRealizadas = [
    'Guardia 12/03/2024 - 1ª hora',
    'Guardia 10/03/2024 - 3ª hora',
  ];

  List<String> guardiasPendientes = [
    'Guardia 20/03/2024 - 2ª hora',
    'Guardia 22/03/2024 - 5ª hora',
  ];

  String? guardiaSeleccionada;

  void eliminarGuardia() {
    if (guardiaSeleccionada != null) {
      setState(() {
        guardiasPendientes.remove(guardiaSeleccionada);
        guardiaSeleccionada = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Guardias')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Guardias Realizadas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent),
                ),
                child: ListView.builder(
                  itemCount: guardiasRealizadas.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(guardiasRealizadas[index]),
                      leading: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Guardias Pendientes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orangeAccent),
                ),
                child: ListView.builder(
                  itemCount: guardiasPendientes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(guardiasPendientes[index]),
                      leading: Icon(
                        guardiaSeleccionada == guardiasPendientes[index]
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color:
                            guardiaSeleccionada == guardiasPendientes[index]
                                ? Colors.blue
                                : null,
                      ),
                      onTap: () {
                        setState(() {
                          // Si la misma guardia ya está seleccionada, deseleccionamos
                          if (guardiaSeleccionada ==
                              guardiasPendientes[index]) {
                            guardiaSeleccionada = null;
                          } else {
                            guardiaSeleccionada = guardiasPendientes[index];
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: eliminarGuardia,
                  child: const Text('Eliminar Guardia Seleccionada'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
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
