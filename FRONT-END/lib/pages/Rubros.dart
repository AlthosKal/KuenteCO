import 'package:flutter/material.dart';
import 'package:tu_app/models/rubro.dart'; // Asume que tienes un modelo de Rubro
import 'package:tu_app/views/crear_rubro_view.dart'; // Vista para crear rubros

class RubrosView extends StatefulWidget {
  const RubrosView({super.key});

  @override
  _RubrosViewState createState() => _RubrosViewState();
}

class _RubrosViewState extends State<RubrosView> {
  // Lista de rubros (puedes cargarla desde una base de datos o servicio)
  List<Rubro> rubros = [
    // Ejemplo de rubros predefinidos
    Rubro(id: '1', nombre: 'Alimentación'),
    Rubro(id: '2', nombre: 'Transporte'),
    Rubro(id: '3', nombre: 'Entretenimiento'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rubros'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Botón para ir a la vista de crear rubro
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Navegar a la vista de crear rubro
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CrearRubroView()
                    )
                ).then((nuevoRubro) {
                  // Cuando se regrese de la vista de crear,
                  // si se creó un nuevo rubro, agregarlo a la lista
                  if (nuevoRubro != null) {
                    setState(() {
                      rubros.add(nuevoRubro);
                    });
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Nuevo Rubro'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),

          // Lista de rubros existentes
          Expanded(
            child: ListView.builder(
              itemCount: rubros.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.category),
                  title: Text(rubros[index].nombre),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón de editar
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Implementar lógica de edición
                        },
                      ),
                      // Botón de eliminar
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            rubros.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Modelo de Rubro (para referencia)
class Rubro {
  final String id;
  final String nombre;

  Rubro({required this.id, required this.nombre});
}