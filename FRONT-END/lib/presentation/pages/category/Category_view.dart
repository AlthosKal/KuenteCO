import 'package:flutter/material.dart';
import 'package:kuenteco/domain/entities/Category_model.dart';
import 'Create_category_view.dart';
import 'package:kuenteco/presentation/widgets/Background_widget.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Rubro> rubros = [
    Rubro(id: '1', nombre: 'Alimentación'),
    Rubro(id: '2', nombre: 'Transporte'),
    Rubro(id: '3', nombre: 'Entretenimiento'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rubros'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Background(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CrearRubroView(),
                    ),
                  ).then((nuevoRubro) {
                    if (nuevoRubro != null) {
                      setState(() {
                        rubros.add(nuevoRubro);
                      });
                    }
                  });
                },
                icon: Icon(Icons.add, color: colorScheme.onPrimary),
                label: Text(
                  'Crear Nuevo Rubro',
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: rubros.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    color: Colors.white.withOpacity(0.8),
                    child: ListTile(
                      leading: Icon(Icons.category, color: colorScheme.primary),
                      title: Text(
                        rubros[index].nombre,
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: colorScheme.primary),
                            onPressed: () {
                              // Implementar lógica de edición
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                rubros.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}