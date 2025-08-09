import 'package:flutter/material.dart';
import '../../controllers/profile_controller.dart';
import '../../dto/profile/profile_detail_dto.dart';

class ProfileButtonWidget extends StatelessWidget {
  final String? profileImageUrl;
  final ProfileController? profileController;
  final ProfileDetailDTO? profile;
  final double radius;

  const ProfileButtonWidget({
    Key? key,
    this.profileImageUrl,
    this.profileController,
    this.profile,
    this.radius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1) Si nos pasan URL directo, lo preferimos (rápido y simple).
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(profileImageUrl!),
      );
    }

    // 2) Si nos pasan controller + profile -> solicitamos la versión actualizada.
    if (profileController != null && profile != null) {
      return FutureBuilder<dynamic>(
        // usa el mismo método que ya tienes en ProfileImageWidget
        future: profileController!.getProfileById(profile!.id),
        builder: (context, snapshot) {
          final currentProfile = snapshot.data ?? profile;
          final imageUrl = currentProfile?.image?.imageUrl as String?;

          // mientras carga y no hay URL, mostramos un spinner pequeño
          if (snapshot.connectionState == ConnectionState.waiting && (imageUrl == null || imageUrl.isEmpty)) {
            return CircleAvatar(
              radius: radius,
              backgroundColor: Colors.white,
              child: SizedBox(
                width: radius,
                height: radius,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          if (imageUrl != null && imageUrl.isNotEmpty) {
            return CircleAvatar(
              radius: radius,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(imageUrl),
            );
          }

          // fallback - placeholder
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.white,
            child: const Icon(Icons.person, color: Colors.grey),
          );
        },
      );
    }

    // 3) Fallback general (sin datos)
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: const Icon(Icons.person, color: Colors.grey),
    );
  }
}
