import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/budget_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../dto/app/budget/budget_dto.dart';
import '../../../dto/app/profile/profile_detail_dto.dart';

class ProfileBudgetAssignmentWidget extends StatefulWidget {
  const ProfileBudgetAssignmentWidget({super.key});

  static Future<bool?> showAssignmentDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const ProfileBudgetAssignmentWidget(),
    );
  }

  @override
  State<ProfileBudgetAssignmentWidget> createState() => _ProfileBudgetAssignmentWidgetState();
}

class _ProfileBudgetAssignmentWidgetState extends State<ProfileBudgetAssignmentWidget> {
  final ProfileController _profileController = ProfileController();
  BudgetDTO? _selectedBudget;
  final Set<int> _selectedProfileIds = {};
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    try {
      await _profileController.loadAllProfiles();
    } catch (e) {
      _showErrorSnackBar('Error al cargar perfiles: $e');
    }
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

  void _selectAllProfiles() {
    setState(() {
      if (_selectedProfileIds.length == _profileController.profiles.value.length) {
        _selectedProfileIds.clear();
      } else {
        _selectedProfileIds.clear();
        _selectedProfileIds.addAll(_profileController.profiles.value.map((p) => p.id));
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _submitAssignments() async {
    if (_selectedBudget == null) {
      _showErrorSnackBar('Por favor selecciona un presupuesto');
      return;
    }

    if (_selectedProfileIds.isEmpty) {
      _showErrorSnackBar('Por favor selecciona al menos un perfil');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = Provider.of<BudgetController>(context, listen: false);
      
      // Crear las asignaciones
      final assignments = _selectedProfileIds.map((profileId) => {
        'profileId': profileId,
        'budgetId': _selectedBudget!.id,
      }).toList();

      await controller.enrollProfileToBudgetBatch(assignments);
      
      Navigator.of(context).pop(true);
      _showSuccessSnackBar('${assignments.length} asignaciones creadas exitosamente');
    } catch (e) {
      _showErrorSnackBar('Error al crear asignaciones: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Asignar Presupuesto a Perfiles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Selector de presupuesto
            const Text(
              'Presupuesto:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Consumer<BudgetController>(
              builder: (context, controller, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<BudgetDTO>(
                    value: _selectedBudget,
                    hint: const Text('Selecciona un presupuesto'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: controller.budgets.map((budget) {
                      return DropdownMenuItem<BudgetDTO>(
                        value: budget,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '\$${budget.totalBudget} - ${budget.status}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (budget) {
                      setState(() {
                        _selectedBudget = budget;
                      });
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // Selector de perfiles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Perfiles:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                ValueListenableBuilder<List<ProfileDetailDTO>>(
                  valueListenable: _profileController.profiles,
                  builder: (context, profiles, child) {
                    return Row(
                      children: [
                        Text(
                          '${_selectedProfileIds.length} de ${profiles.length} seleccionados',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: profiles.isNotEmpty ? _selectAllProfiles : null,
                          child: Text(
                            _selectedProfileIds.length == profiles.length ? 'Desmarcar todo' : 'Marcar todo',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Lista de perfiles
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: _profileController.isLoading,
                builder: (context, isLoading, child) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return ValueListenableBuilder<List<ProfileDetailDTO>>(
                    valueListenable: _profileController.profiles,
                    builder: (context, profiles, child) {
                      if (profiles.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              const Text('No hay perfiles disponibles'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadProfiles,
                                child: const Text('Recargar'),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          final profile = profiles[index];
                          final isSelected = _selectedProfileIds.contains(profile.id);

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) => _toggleProfileSelection(profile.id),
                              title: Text(
                                profile.username,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(profile.email),
                              secondary: CircleAvatar(
                                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                                child: Text(
                                  profile.username.isNotEmpty 
                                      ? profile.username[0].toUpperCase() 
                                      : 'P',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitAssignments,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _selectedProfileIds.isEmpty 
                              ? 'Asignar Presupuesto'
                              : 'Asignar a ${_selectedProfileIds.length} Perfiles',
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}