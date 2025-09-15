import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../../controllers/profile_controller.dart';
import '../../../core/services/app/profile_service.dart';
import '../../../dto/app/profile/profile_detail_dto.dart';
import 'create_profile_widget.dart';
import 'delete_profile_widget.dart';
import 'edit_profile_widget.dart';
import 'profile_buttom_widget.dart';

class ProfilesWidget extends StatefulWidget {
  const ProfilesWidget({super.key});

  @override
  State<ProfilesWidget> createState() => _ProfilesWidgetState();
}

class _ProfilesWidgetState extends State<ProfilesWidget> {
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
      child: const DottedBorderCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.add, color: Colors.white),
            ),
            SizedBox(width: 16),
            Text(
              'Agregar perfil',
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        borderRadius: 16,
        blur: 20,
        alignment: Alignment.bottomCenter,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.2),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.group, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Elige un perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: FutureBuilder<List<ProfileDetailDTO>>(
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
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No tienes perfiles creados',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Crea tu primer perfil para comenzar',
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
                          child: const Column(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No tienes perfiles creados',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Crea tu primer perfil para comenzar',
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
                        return GestureDetector(
                          onTap: () {
                            debugPrint('Perfil seleccionado: ${profile.username}');
                          },
                          child: DottedBorderCard(
                            child: Row(
                              children: [
                                ProfileButtonWidget(
                                  profileController: _profileController,
                                  profile: profile,
                                  radius: 24,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.username,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        profile.email,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
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
                              ],
                            ),
                          ),
                        );
                      }),

                      _buildAddProfileButton(),
                    ],
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