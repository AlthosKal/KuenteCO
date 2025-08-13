import 'package:flutter/material.dart';
import '../../../core/services/app/profile_service.dart';
import '../../../dto/profile/profile_detail_dto.dart';
import '../../../routes/app_routes.dart';
import '../../../screens/home/logged_home_profile_view.dart';

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

  /// ✅ Carga el perfil autenticado para mostrar en el botón de perfil
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
      const SizedBox(height: 10),
      _buildProfileButton(context),
    ],
  );

  /// ✅ LAYOUT DESKTOP
  Widget _buildDesktopLayout(BuildContext context) => Row(
    children: [
      _buildLogo(context, false),
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
      _buildProfileButton(context),
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
            SnackBar(content: Text('Error al cargar perfil: ${e.toString()}')),
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

  /// ✅ Botón de perfil para perfiles
  Widget _buildProfileButton(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuSelection(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person, size: 20),
              SizedBox(width: 8),
              Text('Mi Perfil'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, size: 20),
              SizedBox(width: 8),
              Text('Configuración'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'contact',
          child: Row(
            children: [
              Icon(Icons.contact_mail, size: 20),
              SizedBox(width: 8),
              Text('Contacto'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: _selectedProfile?.image?.imageUrl != null
              ? NetworkImage(_selectedProfile!.image!.imageUrl!)
              : null,
          child: _selectedProfile?.image?.imageUrl == null
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  /// ✅ Maneja las opciones del menú de perfil
  Future<void> _handleMenuSelection(BuildContext context, String value) async {
    switch (value) {
      case 'logout':
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );

          // Cerrar sesión usando el endpoint de perfiles
          await _profileService.logout();

          if (context.mounted) Navigator.of(context).pop();
          widget.onLogout();

          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        } catch (e) {
          if (context.mounted) Navigator.of(context).pop();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al cerrar sesión: ${e.toString()}'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
        break;

      // case 'profile':
      //   _navigateToRoute(context, AppRoutes.loggedHomeProfile);
      //   break;
      case 'settings':
        _navigateToRoute(context, '/profile/settings');
        break;
      case 'contact':
        _navigateToRoute(context, AppRoutes.contactLogged);
        break;
    }
  }

  /// ✅ Botón genérico de navegación
  Widget _buildButton(BuildContext context, String text, String route,
      {Color textColor = Colors.white, bool isLarge = false}) {
    final bool isActive = widget.currentRoute == route;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToRoute(context, route),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 20 : 16,
            vertical: isLarge ? 10 : 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: isLarge ? 17 : 16,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
                ),
              ),
              if (isActive)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  height: 3,
                  width: 20,
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Navegación manteniendo historial
  void _navigateToRoute(BuildContext context, String route) {
    if (route == widget.currentRoute) return;
    Navigator.pushNamed(context, route);
  }
}
