import 'package:flutter/material.dart';

class KuentecoNavbar extends StatelessWidget {
  final String currentRoute;
  final double? logoWidth;
  final double? logoHeight;
  final String logoPath;
  final String logoPlaceholderText;
  final bool useDefaultLogoSize;
  final bool isLoggedIn;

  const KuentecoNavbar({
    super.key,
    this.currentRoute = '/',
    this.logoWidth,
    this.logoHeight,
    this.logoPath = 'assets/img/Logo 2.png',
    this.logoPlaceholderText = 'Logo no disponible',
    this.useDefaultLogoSize = true,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
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
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildAuthButtons(context),
      ),
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
      Row(children: _buildAuthButtons(context)),
    ],
  );

  List<Widget> _buildNavigationButtons(BuildContext context) => [
    _buildButton(
        context,
        'Inicio',
        '/',
        textColor: Colors.white,
    ),
    const SizedBox(width: 20),
    _buildButton(
        context,
        'Suscripciones',
        '/suscripciones',
        textColor: Colors.white,
    ),
    const SizedBox(width: 20),
    _buildButton(
        context,
        'Contáctanos',
        '/contacto',
        textColor: const Color(0xFF890cac),
    ),
  ];

  List<Widget> _buildAuthButtons(BuildContext context) => isLoggedIn
      ? [_buildButton(context, 'Mi Perfil', '/profile')]
      : [
    _buildButton(
        context,
        'Iniciar sesión',
        '/login',
        textColor: const Color(0xFF890cac),
    ),
    const SizedBox(width: 12),
    _buildButton(
      context,
      'Registrarse',
      '/register',
      backgroundColor: const Color(0xFF890cac),
      textColor: Colors.white,
      isLarge: true,
      width: 150,
    ),
  ];

  Widget _buildLogo(BuildContext context, bool isSmallScreen) {
    final double defaultLogoWidth = isSmallScreen ? 220.0 : 250.0;
    final double defaultLogoHeight = isSmallScreen ? 55.0 : 62.5;
    final double finalLogoWidth = logoWidth ?? defaultLogoWidth;
    final double? finalLogoHeight = useDefaultLogoSize ? null : (logoHeight ?? defaultLogoHeight);

    return Image.asset(
      logoPath,
      width: finalLogoWidth,
      height: finalLogoHeight,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        width: finalLogoWidth,
        height: logoHeight ?? defaultLogoHeight,
        child: Center(
          child: Text(
            logoPlaceholderText,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context,
      String text,
      String route, {
        Color? backgroundColor,
        Color? textColor,
        bool isLarge = false,
        double? width,
      }) {
    final isActive = route == currentRoute;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamedAndRemoveUntil(
            context, route, (r) => route == '/' ? false : true),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 20 : 16,
            vertical: isLarge ? 10 : 8,
          ),
          child: Container(
            width: width,
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