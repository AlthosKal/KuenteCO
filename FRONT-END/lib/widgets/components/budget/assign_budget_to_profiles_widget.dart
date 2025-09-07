import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/budget_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../dto/app/budget/budget_dto.dart';
import '../../../dto/app/profile/profile_detail_dto.dart';

class AssignBudgetToProfilesWidget extends StatefulWidget {
  final BudgetDTO budget;

  const AssignBudgetToProfilesWidget({
    super.key,
    required this.budget,
  });

  static Future<bool?> showAssignDialog(BuildContext context, BudgetDTO budget) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AssignBudgetToProfilesWidget(budget: budget),
    );
  }

  @override
  State<AssignBudgetToProfilesWidget> createState() => _AssignBudgetToProfilesWidgetState();
}

class _AssignBudgetToProfilesWidgetState extends State<AssignBudgetToProfilesWidget> {
  final Map<int, bool> _selectedProfiles = {};
  bool _isLoading = false;
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    // Cargar perfiles al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileController = Provider.of<ProfileController>(context, listen: false);
      profileController.loadAllProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.group_add, color: Colors.purple, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Asignar Presupuesto a Perfiles',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Budget info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.purple, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.budget.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text('Monto: \$${widget.budget.totalBudget}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profiles list
            Expanded(
              child: ValueListenableBuilder<List<ProfileDetailDTO>>(
                valueListenable: Provider.of<ProfileController>(context).profiles,
                builder: (context, profiles, child) {
                  if (profiles.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No hay perfiles disponibles',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  final selectedCount = _selectedProfiles.values.where((selected) => selected).length;

                  return Column(
                    children: [
                      // Select all checkbox
                      CheckboxListTile(
                        title: Text(
                          'Seleccionar todos ($selectedCount/${profiles.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        value: _selectAll,
                        onChanged: _isLoading ? null : (value) {
                          setState(() {
                            _selectAll = value ?? false;
                            for (final profile in profiles) {
                              _selectedProfiles[profile.id] = _selectAll;
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Colors.purple,
                      ),
                      const Divider(height: 1),

                      // Profiles list
                      Expanded(
                        child: profiles.length > 5
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: profiles.length,
                              itemBuilder: (context, index) => _buildProfileTile(profiles[index]),
                            )
                          : Column(
                              children: profiles.map(_buildProfileTile).toList(),
                            ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            ValueListenableBuilder<List<ProfileDetailDTO>>(
              valueListenable: Provider.of<ProfileController>(context).profiles,
              builder: (context, profiles, child) {
                final selectedCount = _selectedProfiles.values.where((selected) => selected).length;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCount > 0
                        ? '$selectedCount perfil${selectedCount == 1 ? '' : 'es'} seleccionado${selectedCount == 1 ? '' : 's'}'
                        : 'Ningún perfil seleccionado',
                      style: TextStyle(
                        color: selectedCount > 0 ? Colors.purple : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: (_isLoading || selectedCount == 0) ? null : _assignBudgetToProfiles,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text('Asignar ($selectedCount)'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(ProfileDetailDTO profile) {
    final isSelected = _selectedProfiles[profile.id] ?? false;

    return CheckboxListTile(
      title: Text(
        profile.username,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(profile.email),
      value: isSelected,
      onChanged: _isLoading ? null : (value) {
        setState(() {
          _selectedProfiles[profile.id] = value ?? false;
          _updateSelectAllState();
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.purple,
      enabled: !_isLoading,
      secondary: CircleAvatar(
        backgroundColor: Colors.purple.withValues(alpha: 0.1),
        child: Text(
          profile.username.isNotEmpty ? profile.username[0].toUpperCase() : 'P',
          style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _updateSelectAllState() {
    final profileController = Provider.of<ProfileController>(context, listen: false);
    final profiles = profileController.profiles.value;
    final selectedCount = _selectedProfiles.values.where((selected) => selected).length;
    final totalCount = profiles.length;

    setState(() {
      _selectAll = selectedCount == totalCount;
    });
  }

  Future<void> _assignBudgetToProfiles() async {
    final selectedProfileIds = _selectedProfiles.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedProfileIds.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final budgetController = Provider.of<BudgetController>(context, listen: false);

      // Asignar presupuesto a cada perfil seleccionado
      for (final profileId in selectedProfileIds) {
        await budgetController.enrollProfileToBudget(profileId, widget.budget.id);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Presupuesto "${widget.budget.name}" asignado a ${selectedProfileIds.length} perfil${selectedProfileIds.length == 1 ? '' : 'es'} exitosamente'
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Error al asignar presupuesto',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('$e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}