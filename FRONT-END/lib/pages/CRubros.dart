import 'package:flutter/material.dart';
import 'package:tu_app/models/rubro.dart'; // Mismo modelo de Rubro

class CrearRubroView extends StatefulWidget {
  const CrearRubroView({Key? key}) : super(key: key);

  @override
  _CrearRubroViewState createState() => _CrearRubroViewState();
}

class _CrearRubroViewState extends State<CrearRubroView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Rubro'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Rubro',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre para el rubro';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Crear nuevo rubro
                    final nuevoRubro = Rubro(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        nombre: _nombreController.text
                    );

                    // Regresar a la vista anterior con el nuevo rubro
                    Navigator.pop(context, nuevoRubro);
                  }
                },
                child: const Text('Guardar Rubro'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }
}