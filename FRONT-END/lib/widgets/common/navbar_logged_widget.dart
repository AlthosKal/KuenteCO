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
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
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

  List<Widget> _buildNavigationButtons(BuildContext context) => [
    _buildButton(context, 'Inicio', '/logged_home_view.dart'),
    const SizedBox(width: 20),
    _buildButton(context, 'Rubros', '/Category_view'),
    const SizedBox(width: 20),
    _buildButton(context, 'Presupuestos', '/Account_home_view'),
  ];

  Widget _buildLogo(BuildContext context, bool isSmallScreen) {
    final double defaultWidth = isSmallScreen ? 220.0 : 250.0;
    final double defaultHeight = isSmallScreen ? 55.0 : 62.5;
    final double width = logoWidth ?? defaultWidth;
    final double height = useDefaultLogoSize ? defaultHeight : (logoHeight ?? defaultHeight);

    return GestureDetector(
      onTap: () => _navigateToRoute(context, '/home'),
      child: Image.asset(
        logoPath,
        width: width,
        height: useDefaultLogoSize ? null : height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => SizedBox(
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

  Future<void> _handleMenuSelection(BuildContext context, String value) async {
    switch (value) {
      case 'logout':
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );

          await authRepository.logout();

          if (context.mounted) Navigator.of(context).pop();
          onLogout();

          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
                  (route) => false,
            );
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
      case 'account':
        _navigateToRoute(context, '/account');
        break;
      case 'add_profile':
        _navigateToRoute(context, '/add-profile');
        break;
      case 'subscription':
        _navigateToRoute(context, '/subscription');
        break;
      case 'contact':
        _navigateToRoute(context, '/contact');
        break;
    }
  }

  Widget _buildButton(
      BuildContext context,
      String text,
      String route, {
        Color textColor = Colors.white,
        bool isLarge = false,
      }) {
    final bool isActive = currentRoute == route;

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

  void _navigateToRoute(BuildContext context, String route) {
    if (route == currentRoute) return;
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
  }
}
