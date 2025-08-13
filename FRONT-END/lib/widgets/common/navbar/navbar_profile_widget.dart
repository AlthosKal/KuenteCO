import 'package:flutter/material.dart';
import '../../../core/services/app/profile_service.dart';
import '../../../dto/app/profile/profile_detail_dto.dart';
import '../../../screens/home/logged_home_profile_view.dart';
import '../../profile/profile_buttom_widget.dart';

/// ✅ Navbar principal para perfiles logueados
class KuentecoProfileNavbar extends StatefulWidget {
  final String currentRoute;
  final double? logoWidth;
  final double? logoHeight;
  final String logoPath;
  final String logoPlaceholderText;
  final bool useDefaultLogoSize;
  final VoidCallback onLogout;

  const KuentecoProfileNavbar({
    super.key,
    required this.currentRoute,
    this.logoWidth,
    this.logoHeight,
    this.logoPath = 'assets/img/Logo 2.png',
    this.logoPlaceholderText = 'Logo no disponible',
    this.useDefaultLogoSize = true,
    required this.onLogout,
  });

  @override
  State<KuentecoProfileNavbar> createState() => _KuentecoProfileLoggedNavbarState();
}

class _KuentecoProfileLoggedNavbarState extends State<KuentecoProfileNavbar> {
  final ProfileService _profileService = ProfileService();
  ProfileDetailDTO? _selectedProfile;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// ✅ Carga el perfil autenticado
  Future<void> _loadProfileData() async {
    try {
      final profile = await _profileService.getAuthenticatedProfile();
      if (mounted) {
        setState(() {
          _selectedProfile = profile;
        });
      }
    } catch (e) {
      print('Error cargando datos del perfil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: isSmallScreen ? _buildMobileLayout(context) : _buildDesktopLayout(context),
    );
  }

  /// ✅ LAYOUT MOBILE
  Widget _buildMobileLayout(BuildContext context) => Column(
    children: [
      Center(child: _buildLogo(context, true)),
      const SizedBox(height: 10),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisAlignment: MainAxisAlignment.center),
      ),
      const SizedBox(height: 10),
      _buildProfileButton(), // ✅ Reemplazado por el nuevo widget
    ],
  );

  /// ✅ LAYOUT DESKTOP
  Widget _buildDesktopLayout(BuildContext context) => Row(
    children: [
      _buildLogo(context, false),
      Expanded(
        child: Row(mainAxisAlignment: MainAxisAlignment.center),
      ),
      _buildProfileButton(),
    ],
  );

  /// ✅ Logo que navega a la vista principal del perfil
  Widget _buildLogo(BuildContext context, bool isSmallScreen) {
    final double defaultWidth = isSmallScreen ? 220.0 : 250.0;
    final double defaultHeight = isSmallScreen ? 55.0 : 62.5;
    final double width = widget.logoWidth ?? defaultWidth;
    final double height =
    widget.useDefaultLogoSize ? defaultHeight : (widget.logoHeight ?? defaultHeight);

    return GestureDetector(
      onTap: () async {
        try {
          final profile = await _profileService.getAuthenticatedProfile();

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LoggedHomeProfileView(
                profileName: profile.username,
                profileImageUrl: profile.image?.imageUrl ?? '',
              ),
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar perfil: $e')),
          );
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Image.asset(
          widget.logoPath,
          width: width,
          height: widget.useDefaultLogoSize ? null : height,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => SizedBox(
            width: width,
            height: height,
            child: Center(
              child: Text(
                widget.logoPlaceholderText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton() {
    return ProfileButtonWidget(
      profileImageUrl: _selectedProfile?.image?.imageUrl ?? '',
      profile: _selectedProfile,
    );
  }
}
