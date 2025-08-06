import 'package:KuenteCO/widgets/common/profile_buttom_business_widget.dart';
import 'package:KuenteCO/widgets/common/profile_buttom_personal_widget.dart';
import 'package:flutter/material.dart';
import '../../../core/services/app/auth_service.dart';
import '../../../dto/auth/response/user_detail_dto.dart';
import '../../../routes/app_routes.dart';
import '../../../screens/home/logged_home_business_view.dart';
import '../../../screens/home/logged_home_personal_view.dart';

/// ✅ Navbar principal para usuarios logueados
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
  final AuthService _userService = AuthService();
  UserDetailDTO? _selectedProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// ✅ Carga el usuario autenticado para mostrar en el botón de perfil
  Future<void> _loadUserProfile() async {
    try {
      final user = await _userService.getAuthenticatedUser();
      if (mounted) {
        setState(() {
          _selectedProfile = user;
        });
      }
    } catch (e) {
      print('Error cargando perfil de usuario: $e');
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
          children: _buildNavigationButtons(context),
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
          children: _buildNavigationButtons(context),
        ),
      ),
      _buildProfileButton(context),
    ],
  );

  /// ✅ Botones de navegación
  List<Widget> _buildNavigationButtons(BuildContext context) => [
    _buildButton(context, 'Inicio', AppRoutes.homePersonal),
    const SizedBox(width: 20),
    _buildButton(context, 'Rubros', '/Category_view'),
    const SizedBox(width: 20),
    _buildButton(context, 'Presupuestos', '/Account_home_view'),
  ];

  /// ✅ Logo con navegación dinámica según tipo de usuario
  Widget _buildLogo(BuildContext context, bool isSmallScreen) {
    final double defaultWidth = isSmallScreen ? 220.0 : 250.0;
    final double defaultHeight = isSmallScreen ? 55.0 : 62.5;
    final double width = widget.logoWidth ?? defaultWidth;
    final double height =
    widget.useDefaultLogoSize ? defaultHeight : (widget.logoHeight ?? defaultHeight);

    return GestureDetector(
      onTap: () async {
        try {
          final user = await _userService.getAuthenticatedUser();

          if (!mounted) return;
          if (user.userType.toLowerCase() == 'personal') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LoggedHomePersonalView(
                  userName: user.username,
                  profileImageUrl: user.image?.imageUrl ?? '',
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LoggedHomeBusinessView(
                  userName: user.username,
                  profileImageUrl: user.image?.imageUrl ?? '',
                ),
              ),
            );
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar usuario: ${e.toString()}')),
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

  /// ✅ Botón de perfil (usa widget personalizado según tipo de usuario)
  Widget _buildProfileButton(BuildContext context) {
    if (_selectedProfile?.userType.toLowerCase() == 'personal') {
      return ProfileButtonPersonal(
        profileImageUrl: _selectedProfile?.image?.imageUrl ?? '',
      );
    } else {
      return ProfileButtonBusiness(
        profileImageUrl: _selectedProfile?.image?.imageUrl ?? '',
      );
    }
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

          await _userService.logout();

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

      case 'contact':
        _navigateToRoute(context, AppRoutes.contactLogged);
        break;
      case 'account':
        _navigateToRoute(context, '/account');
        break;
      case 'add_profile':
        _navigateToRoute(context, '/add-profile');
        break;
      case 'subscription':
        _navigateToRoute(context, '/subscription');
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

  /// ✅ Navegación manteniendo historial (excepto logout)
  void _navigateToRoute(BuildContext context, String route) {
    if (route == widget.currentRoute) return;
    Navigator.pushNamed(context, route);
  }
}
