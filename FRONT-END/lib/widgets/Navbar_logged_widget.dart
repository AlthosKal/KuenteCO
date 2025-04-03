import 'package:flutter/material.dart';

class KuentecoNavbar extends StatelessWidget {
  final String currentRoute;
  final double? logoWidth;
  final double? logoHeight;
  final String logoPath;
  final String logoPlaceholderText;
  final bool useDefaultLogoSize;
  final VoidCallback onLogout;

  const KuentecoNavbar({
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
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0);

    return Container(
      padding: padding,
      child: isSmallScreen ? _buildMobileLayout(context) : _buildDesktopLayout(context),
    );
  }

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

  List<Widget> _buildNavigationButtons(BuildContext context) {
    return [
      _buildButton(
        context,
        'Inicio',
        '/loggedIn',
        textColor: Colors.white,
      ),
      const SizedBox(width: 20),
      _buildButton(
        context,
        'Rubros',
        '/pages/Category_view.dart',
        textColor: Colors.white,
      ),
      const SizedBox(width: 20),
      _buildButton(
        context,
        'Dashboard',
        '/dashboard',
        textColor: Colors.white,
      ),
    ];
  }

  Widget _buildLogo(BuildContext context, bool isSmallScreen) {
    final double defaultLogoWidth = isSmallScreen ? 220 : 250;
    final double defaultLogoHeight = isSmallScreen ? 55 : 62.5;
    final double width = logoWidth ?? defaultLogoWidth;
    final double height = logoHeight ?? defaultLogoHeight;

    return GestureDetector(
      onTap: () => Navigator.pushNamedAndRemoveUntil(
          context,
          '/loggedIn',
              (route) => false
      ),
      child: Image.asset(
        logoPath,
        width: width,
        height: useDefaultLogoSize ? null : height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: width,
          height: height,
          child: Center(
            child: Text(
              logoPlaceholderText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return PopupMenuButton<String>(
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, color: Theme.of(context).primaryColor),
      ),
      itemBuilder: (BuildContext context) => const [
        PopupMenuItem<String>(value: 'account', child: Text('Mi cuenta')),
        PopupMenuItem<String>(value: 'add_profile', child: Text('Agregar perfil')),
        PopupMenuItem<String>(value: 'subscription', child: Text('Suscripción')),
        PopupMenuItem<String>(value: 'contact', child: Text('Contáctanos')),
        PopupMenuItem<String>(value: 'logout', child: Text('Cerrar sesión')),
      ],
      onSelected: (value) => _handleMenuSelection(context, value),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'logout':
        onLogout();
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false,
        );
        break;
      case 'account':
        Navigator.pushNamed(context, '/account');
        break;
      case 'add_profile':
        Navigator.pushNamed(context, '/add-profile');
        break;
      case 'subscription':
        Navigator.pushNamed(context, '/subscription');
        break;
      case 'contact':
        Navigator.pushNamed(context, '/contact');
        break;
    }
  }

  Widget _buildButton(
      BuildContext context,
      String text,
      String route, {
        Color? textColor,
        bool isLarge = false,
      }) {
    final bool isActive = currentRoute == route;
    final horizontalPadding = isLarge ? 20.0 : 16.0;
    final verticalPadding = isLarge ? 10.0 : 8.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToRoute(context, route),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
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
              if (isActive)
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
    );
  }

  void _navigateToRoute(BuildContext context, String route) {
    if (route == currentRoute) return;

    if (route == '/loggedIn') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
            (route) => false,
      );
    } else {
      Navigator.pushNamed(context, route);
    }
  }
}