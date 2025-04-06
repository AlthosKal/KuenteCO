import 'package:flutter/material.dart';
import 'package:kuenteco/domain/entities/Category_model.dart';
import 'package:kuenteco/presentation/widgets/Background_widget.dart';

class CrearRubroView extends StatefulWidget {
  const CrearRubroView({super.key});

  @override
  _CrearRubroViewState createState() => _CrearRubroViewState();
}

class _CrearRubroViewState extends State<CrearRubroView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Rubro'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Background(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Rubro',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    labelStyle: TextStyle(color: colorScheme.primary),
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
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
                      final nuevoRubro = Rubro(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          nombre: _nombreController.text
                      );
                      Navigator.pop(context, nuevoRubro);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Guardar Rubro'),
                )
              ],
            ),
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