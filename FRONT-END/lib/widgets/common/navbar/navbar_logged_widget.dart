import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/services/app/auth_service.dart';
import '../../../core/services/app/profile_service.dart';
import '../../../dto/app/auth/response/user_detail_dto.dart';
import '../../../dto/app/profile/profile_detail_dto.dart';
import '../../../screens/home/logged_home_business_view.dart';
import '../../../screens/home/logged_home_personal_view.dart';
import '../../../screens/home/logged_home_profile_view.dart';
import '../../components/profile/profile_buttom_widget.dart';
import '../../components/user/user_buttom_business_widget.dart';
import '../../components/user/user_buttom_personal_widget.dart';

class KuentecoLoggedNavbar extends StatefulWidget {
  final String currentRoute;
  final double? logoWidth;
  final double? logoHeight;
  final String logoPath;
  final String logoPlaceholderText;
  final bool useDefaultLogoSize;
  final VoidCallback onLogout;

  const KuentecoLoggedNavbar({
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
  State<KuentecoLoggedNavbar> createState() => _KuentecoLoggedNavbarState();
}

class _KuentecoLoggedNavbarState extends State<KuentecoLoggedNavbar> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  UserDetailDTO? _authenticatedUser;
  ProfileDetailDTO? _authenticatedProfile;
  String? _currentRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthenticatedData();
  }

  /// â Detecta automáticamente el tipo de autenticación y carga los datos correspondientes
  Future<void> _loadAuthenticatedData() async {
    try {
      // Obtener el rol guardado en storage
      _currentRole = await _storage.read(key: 'role');
      
      if (_currentRole == 'ROLE_PROFILE') {
        // Es un perfil autenticado
        final profile = await _profileService.getAuthenticatedProfile();
        if (mounted) {
          setState(() {
            _authenticatedProfile = profile;
            _authenticatedUser = null;
            _isLoading = false;
          });
        }
      } else {
        // Es un usuario autenticado (ROLE_USER u otros)
        final user = await _authService.getAuthenticatedUser();
        if (mounted) {
          setState(() {
            _authenticatedUser = user;
            _authenticatedProfile = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error cargando datos de autenticación: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: isSmallScreen ? _buildMobileLayout(context) : _buildDesktopLayout(context),
    );
  }

  /// â LAYOUT MOBILE
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

  /// â LAYOUT DESKTOP
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

  /// â Logo con navegación dinámica según tipo de autenticación
  
  Widget _buildLogo(BuildContext context, bool isSmallScreen) {
    final double defaultWidth = isSmallScreen ? 220.0 : 250.0;
    final double defaultHeight = isSmallScreen ? 55.0 : 62.5;
    final double width = widget.logoWidth ?? defaultWidth;
    final double height =
    widget.useDefaultLogoSize ? defaultHeight : (widget.logoHeight ?? defaultHeight);

    return GestureDetector(
      onTap: () => _navigateToHome(context),
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

  /// â Botón de perfil que detecta automáticamente el tipo de autenticación
  Widget _buildProfileButton(BuildContext context) {
    if (_currentRole == 'ROLE_PROFILE' && _authenticatedProfile != null) {
      // Es un perfil autenticado - usar ProfileButtonWidget
      return ProfileButtonWidget(
        profileImageUrl: _authenticatedProfile!.image?.imageUrl ?? '',
        profile: _authenticatedProfile,
      );
    } else if (_authenticatedUser != null) {
      // Es un usuario autenticado - usar widget según su tipo
      if (_authenticatedUser!.userType.toLowerCase() == 'personal') {
        return UserButtomPersonalWidget(
          profileImageUrl: _authenticatedUser!.image?.imageUrl ?? '',
        );
      } else {
        return ProfileButtonBusiness(
          profileImageUrl: _authenticatedUser!.image?.imageUrl ?? '',
        );
      }
    }
    
    // Fallback si no hay autenticación
    return const SizedBox.shrink();
  }


  /// â Navegación dinámica al home según el tipo de autenticación
  Future<void> _navigateToHome(BuildContext context) async {
    if (!mounted) return;

    try {
      if (_currentRole == 'ROLE_PROFILE' && _authenticatedProfile != null) {
        // Navegar al home del perfil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoggedHomeProfileView(
              profileName: _authenticatedProfile!.username,
              profileImageUrl: _authenticatedProfile!.image?.imageUrl ?? '',
            ),
          ),
        );
      } else if (_authenticatedUser != null) {
        // Navegar según el tipo de usuario
        if (_authenticatedUser!.userType.toLowerCase() == 'personal') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LoggedHomePersonalView(
                userName: _authenticatedUser!.username,
                profileImageUrl: _authenticatedUser!.image?.imageUrl ?? '',
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LoggedHomeBusinessView(
                userName: _authenticatedUser!.username,
                profileImageUrl: _authenticatedUser!.image?.imageUrl ?? '',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al navegar: $e')),
      );
    }
  }

  /// â Navegación manteniendo historial (excepto logout)
  void _navigateToRoute(BuildContext context, String route) {
    if (route == widget.currentRoute) return;
    Navigator.pushNamed(context, route);
  }
}
