import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/category_controller.dart';
import '../../../core/services/app/profile_service.dart';
import '../../../dto/app/category/batch_enrollment_request_dto.dart';
import '../../../dto/app/category/category_dto.dart';
import '../../../dto/app/profile/profile_detail_dto.dart';

class BatchAssignCategoryWidget extends StatefulWidget {
  const BatchAssignCategoryWidget({super.key});

  @override
  State<BatchAssignCategoryWidget> createState() => _BatchAssignCategoryWidgetState();

  static Future<bool?> showBatchAssignDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const BatchAssignCategoryWidget(),
    );
  }
}

class _BatchAssignCategoryWidgetState extends State<BatchAssignCategoryWidget> {
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;
  String? _errorMessage;

  // Selecciones
  Set<int> _selectedCategoryIds = {};
  Set<int> _selectedProfileIds = {};

  // Datos
  List<CategoryDTO> _availableCategories = [];
  List<ProfileDetailDTO> _availableProfiles = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categoryController = Provider.of<CategoryController>(context, listen: false);

      // Cargar categorías y perfiles en paralelo
      await Future.wait([
        categoryController.loadCategories(),
        _loadProfiles(),
      ]);

      setState(() {
        _availableCategories = categoryController.categories;
      });

      print('📌 BatchAssignCategoryWidget: Loaded ${_availableCategories.length} categories and ${_availableProfiles.length} profiles');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos: $e';
      });
      print('❌ BatchAssignCategoryWidget: Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProfiles() async {
    _availableProfiles = await _profileService.getAllProfiles();
  }

  void _toggleCategorySelection(int categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _toggleProfileSelection(int profileId) {
    setState(() {
      if (_selectedProfileIds.contains(profileId)) {
        _selectedProfileIds.remove(profileId);
      } else {
        _selectedProfileIds.add(profileId);
      }
    });
  }

  void _selectAllCategories() {
    setState(() {
      _selectedCategoryIds.clear();
      _selectedCategoryIds.addAll(_availableCategories.map((c) => c.id));
    });
  }

  void _selectAllProfiles() {
    setState(() {
      _selectedProfileIds.clear();
      _selectedProfileIds.addAll(_availableProfiles.map((p) => p.id));
    });
  }

  void _clearSelections() {
    setState(() {
      _selectedCategoryIds.clear();
      _selectedProfileIds.clear();
    });
  }

  Future<void> _performBatchAssignment() async {
    if (_selectedCategoryIds.isEmpty || _selectedProfileIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una categoría y un perfil'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Crear lista de asignaciones
    List<BatchEnrollmentRequestDTO> enrollments = [];
    for (int categoryId in _selectedCategoryIds) {
      for (int profileId in _selectedProfileIds) {
        enrollments.add(BatchEnrollmentRequestDTO(
          profileId: profileId,
          categoryId: categoryId,
        ));
      }
    }

    final totalAssignments = enrollments.length;
    print('📌 BatchAssignCategoryWidget: Creating $totalAssignments assignments');

    // Mostrar confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Asignaciones Masivas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Se crearán $totalAssignments asignaciones:'),
            const SizedBox(height: 8),
            Text('• ${_selectedCategoryIds.length} categorías seleccionadas'),
            Text('• ${_selectedProfileIds.length} perfiles seleccionados'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Las asignaciones duplicadas serán ignoradas automáticamente.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Asignar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categoryController = Provider.of<CategoryController>(context, listen: false);
      await categoryController.enrollProfilesToCategoriesBatch(enrollments);

      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Se crearon $totalAssignments asignaciones exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Cerrar el diálogo
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al crear asignaciones: $e';
      });
      print('❌ BatchAssignCategoryWidget: Error creating batch assignments: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.assignment_add, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Asignación Masiva de Categorías',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // Error message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Loading indicator
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              // Content
              Expanded(
                child: Row(
                  children: [
                    // Categorías
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Categorías (${_selectedCategoryIds.length}/${_availableCategories.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: _selectAllCategories,
                                child: const Text('Todas'),
                              ),
                              TextButton(
                                onPressed: () => setState(() => _selectedCategoryIds.clear()),
                                child: const Text('Ninguna'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                itemCount: _availableCategories.length,
                                itemBuilder: (context, index) {
                                  final category = _availableCategories[index];
                                  final isSelected = _selectedCategoryIds.contains(category.id);

                                  return CheckboxListTile(
                                    value: isSelected,
                                    onChanged: (_) => _toggleCategorySelection(category.id),
                                    title: Text(
                                      category.name,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Presupuesto: \$${category.description.assignedBudget}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    secondary: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: category.description.state.name == 'ACTIVE'
                                            ? Colors.green.withValues(alpha: 0.2)
                                            : Colors.grey.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        category.description.state.name,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: category.description.state.name == 'ACTIVE'
                                              ? Colors.green[700]
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    dense: true,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Perfiles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Perfiles (${_selectedProfileIds.length}/${_availableProfiles.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: _selectAllProfiles,
                                child: const Text('Todos'),
                              ),
                              TextButton(
                                onPressed: () => setState(() => _selectedProfileIds.clear()),
                                child: const Text('Ninguno'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                itemCount: _availableProfiles.length,
                                itemBuilder: (context, index) {
                                  final profile = _availableProfiles[index];
                                  final isSelected = _selectedProfileIds.contains(profile.id);

                                  return CheckboxListTile(
                                    value: isSelected,
                                    onChanged: (_) => _toggleProfileSelection(profile.id),
                                    title: Text(
                                      profile.username,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text(
                                      profile.email,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    secondary: CircleAvatar(
                                      backgroundColor: Colors.blue.withValues(alpha: 0.2),
                                      child: Text(
                                        profile.username.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    dense: true,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Se crearán ${_selectedCategoryIds.length * _selectedProfileIds.length} asignaciones',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  TextButton(
                    onPressed: _clearSelections,
                    child: const Text('Limpiar selección'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: (_selectedCategoryIds.isEmpty || _selectedProfileIds.isEmpty)
                        ? null
                        : _performBatchAssignment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Asignar'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
