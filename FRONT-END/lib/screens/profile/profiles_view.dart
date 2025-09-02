import 'package:flutter/material.dart';

import '../../controllers/profile_controller.dart';
import '../../core/services/app/profile_service.dart';
import '../../dto/app/profile/profile_detail_dto.dart';
import '../../widgets/components/profile/create_profile_widget.dart';
import '../../widgets/components/profile/delete_profile_widget.dart';
import '../../widgets/components/profile/edit_profile_widget.dart';
import '../../widgets/components/profile/profile_buttom_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  late final ProfileController _profileController;
  late Future<List<ProfileDetailDTO>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    _profileController = ProfileController(profileService: _profileService);
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

  Widget _buildAddProfileButton() {
    return GestureDetector(
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
    );
  }

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
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
            // Mientras carga
            return Column(
              children: [
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildAddProfileButton(),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            // Error o sin perfiles
            return Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.person_outline,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No tienes perfiles creados",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Crea tu primer perfil para comenzar",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildAddProfileButton(),
                ),
              ],
            );
          }

          final profiles = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (profiles.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.person_outline,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No tienes perfiles creados",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Crea tu primer perfil para comenzar",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              // 🔹 Lista de perfiles usando ProfileButtonWidget
              ...profiles.map((profile) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  child: ListTile(
                    leading: ProfileButtonWidget(
                      profileController: _profileController,
                      profile: profile,
                      radius: 24,
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
                                profile: profile,
                                profileController: _profileController,
                                onSuccess: _onAccountDeleted,
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
                      debugPrint("Perfil seleccionado: ${profile.username}");
                    },
                  ),
                );
              }),

              _buildAddProfileButton(),
            ],
          );
        },
      ),
    );
  }
}

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
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
