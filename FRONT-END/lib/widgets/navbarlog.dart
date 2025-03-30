import 'package:flutter/material.dart';

class KuentecoNavbar extends StatelessWidget {
  final String currentRoute;
  final double? logoWidth;
  final double? logoHeight;
  final String logoPath;
  final String logoPlaceholderText;
  final bool useDefaultLogoSize;
  final bool isLoggedIn;
  final VoidCallback? onLogout;

  const KuentecoNavbar({
    super.key,
    this.currentRoute = '/',
    this.logoWidth,
    this.logoHeight,
    this.logoPath = 'Img/Logo 2.png',
    this.logoPlaceholderText = 'Logo no disponible',
    this.useDefaultLogoSize = true,
    required this.isLoggedIn,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (isSmallScreen) {
            return _buildMobileLayout(context);
          } else {
            return _buildDesktopLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildAuthButtons(context),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        _buildLogo(context, false),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildNavigationButtons(context),
          ),
        ),
        Row(
          children: _buildAuthButtons(context),
        ),
      ],
    );
  }

  List<Widget> _buildNavigationButtons(BuildContext context) {
    final buttons = [
      _buildButton(context, 'Inicio', '/iniciolog'),
      const SizedBox(width: 20),
      _buildButton(context, 'Rubros', '/Rubros'),
    ];

    if (isLoggedIn) {
      buttons.addAll([
        const SizedBox(width: 20),
        _buildButton(context, 'Dashboard', '/dashboard'),
      ]);
    }

    return buttons;
  }

  List<Widget> _buildAuthButtons(BuildContext context) {
    if (isLoggedIn) {
      return [
        _buildProfileButton(context),
        const SizedBox(width: 12),
        _buildLogoutButton(context),
      ];
    } else {
      return [
        _buildButton(context, 'Iniciar sesión', '/login'),
        const SizedBox(width: 12),
        _buildButton(
          context,
          'Registrarse',
          '/register',
          backgroundColor: Colors.white,
          textColor: const Color(0xFF890cac),
          isLarge: true,
        ),
      ];
    }
  }

  Widget _buildLogo(BuildContext context, bool isSmallScreen) {
    final double defaultLogoWidth = isSmallScreen ? 220 : 250;
    final double defaultLogoHeight = isSmallScreen ? 55 : 62.5;
    final double finalLogoWidth = logoWidth ?? defaultLogoWidth;
    final double finalLogoHeight = logoHeight ?? defaultLogoHeight;

    return GestureDetector(
      onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
      child: Image.asset(
        logoPath,
        width: finalLogoWidth,
        height: useDefaultLogoSize ? null : finalLogoHeight,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: finalLogoWidth,
            height: finalLogoHeight,
            child: Center(
              child: Text(
                logoPlaceholderText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return PopupMenuButton<String>(
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, color: Theme.of(context).primaryColor),
      ),
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'profile',
          child: Text('Mi Perfil'),
        ),
        const PopupMenuItem<String>(
          value: 'settings',
          child: Text('Configuración'),
        ),
      ],
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.pushNamed(context, '/profile');
        } else if (value == 'settings') {
          Navigator.pushNamed(context, '/settings');
        }
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return _buildButton(
      context,
      'Cerrar sesión',
      '/logout',
      backgroundColor: Colors.white,
      textColor: const Color(0xFF890cac),
      isLarge: true,
      onPressed: onLogout,
    );
  }

  Widget _buildButton(
      BuildContext context,
      String text,
      String route, {
        Color? backgroundColor,
        Color? textColor,
        bool isLarge = false,
        VoidCallback? onPressed,
      }) {
    final bool isActive = route == currentRoute;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed ?? () {
          if (route == '/logout') {
            if (onLogout != null) onLogout!();
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context,
                route,
                    (r) => route == '/' ? false : true
            );
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isLarge ? 20 : 16,
              vertical: isLarge ? 10 : 8
          ),
          child: Container(
            decoration: backgroundColor != null
                ? BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            )
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: isLarge ? 17 : 16,
                    fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
                  ),
                ),
                if (isActive && backgroundColor == null)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    height: 3,
                    width: 20,
                    decoration: BoxDecoration(
                      color: (textColor ?? Colors.white).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}