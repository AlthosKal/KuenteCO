import 'package:flutter/material.dart';
import '../../core/services/app/profile_service.dart';
import '../../dto/profile/profile_detail_dto.dart';
import '../../widgets/profile/create_profile_widget.dart';
import '../../widgets/profile/delete_profile_widget.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
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
      _loadProfiles(); // recargar perfiles al crear uno nuevo
    });
  }

  void _onAccountDeleted() {
    setState(() {
      _loadProfiles(); // recargar perfiles al eliminar uno
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfiles de Usuario"),
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
          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return ListTile(
                title: Text(profile.username),
                subtitle: Text(profile.email),
                trailing: DeleteProfileButton(
                  profileId: profile.id,
                  onSuccess: _onAccountDeleted,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateProfileWidget(
                onProfileCreated: _onAccountCreated,
              ),
            ),
          );
        },
      ),
    );
  }
}
