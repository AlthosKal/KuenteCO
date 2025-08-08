import 'package:flutter/material.dart';
import '../../core/services/app/profile_service.dart';
import '../../dto/profile/profile_detail_dto.dart';
import '../../widgets/profile/create_profile_widget.dart';
import '../../widgets/profile/delete_profile_widget.dart';
import '../../widgets/profile/edit_profile_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  late Future<List<ProfileDetailDTO>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void _loadProfiles() {
    _profilesFuture = _profileService.getAllProfiles();
  }

  void _onAccountCreated() {
    setState(() {
      _loadProfiles();
    });
  }

  void _onAccountDeleted() {
    setState(() {
      _loadProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Elige un perfil"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ProfileDetailDTO>>(
        future: _profilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final profiles = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...profiles.map((profile) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person, size: 28),
                    ),
                    title: Text(
                      profile.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(profile.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.purple),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => EditProfile(
                                profile: profile,  // El perfil que se está editando
                                onSuccess: _onAccountDeleted,  // Función para recargar después de editar
                              ),
                            );
                          },
                        ),
                        DeleteProfileButton(
                          profileId: profile.id,
                          onSuccess: _onAccountDeleted,
                        ),
                      ],
                    ),
                    onTap: () {
                      // Seleccionar perfil
                      print("Perfil seleccionado: ${profile.username}");
                    },
                  ),
                );
              }).toList(),

              // Botón para agregar perfil con borde punteado
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateProfileWidget(
                        onProfileCreated: _onAccountCreated,
                      ),
                    ),
                  );
                },
                child: DottedBorderCard(
                  child: Row(
                    children: const [
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                      SizedBox(width: 16),
                      Text(
                        "Agregar perfil",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Este widget genera el borde punteado tipo imagen
class DottedBorderCard extends StatelessWidget {
  final Widget child;
  const DottedBorderCard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
        // Aquí puedes reemplazar con un paquete como dotted_border
        // si quieres líneas punteadas reales
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
