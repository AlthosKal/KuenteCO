import 'package:flutter/material.dart';

class KuentecoNavbar extends StatelessWidget {
  final String currentRoute;
  final double? logoWidth, logoHeight;
  final String logoPath, logoPlaceholderText;
  final bool useDefaultLogoSize;

  const KuentecoNavbar({
    super.key,
    this.currentRoute = '/',
    this.logoWidth,
    this.logoHeight,
    this.logoPath = 'assets/img/Logo 2.png',
    this.logoPlaceholderText = 'Logo no disponible',
    this.useDefaultLogoSize = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: isSmallScreen ? _buildMobileLayout(context) : _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildLogo(context, true),
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
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildNavigationButtons(context),
          ),
        ),
      ),
      Row(children: _buildAuthButtons(context)),
    ],
  );

  List<Widget> _buildNavigationButtons(BuildContext context) => [
    _buildNavButton(context, 'Inicio', '/'),
    const SizedBox(width: 20),
    _buildNavButton(context, 'Suscripciones', '/suscripciones'),
    const SizedBox(width: 20),
    _buildNavButton(context, 'Contáctanos', '/contacto'),
  ];

  List<Widget> _buildAuthButtons(BuildContext context) => [
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
      width: 150,
    ),
  ];

  Widget _buildNavButton(BuildContext context, String text, String route) =>
      _buildButton(context, text, route, textColor: Colors.white);

  Widget _buildLogo(BuildContext context, bool isSmallScreen) {
    final defaultWidth = isSmallScreen ? 220.0 : 250.0;
    final defaultHeight = isSmallScreen ? 55.0 : 62.5;
    final width = logoWidth ?? defaultWidth;
    final height = useDefaultLogoSize ? null : (logoHeight ?? defaultHeight);

    return Image.asset(
      logoPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(
        width: width,
        height: height ?? defaultHeight,
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
        Color textColor = Colors.white,
        bool isLarge = false,
        double? width,
      }) {
    final isActive = route == currentRoute;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.pushNamedAndRemoveUntil(
            context, route, (r) => route == '/' ? false : true),
        child: Container(
          width: width,
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 20 : 16,
            vertical: isLarge ? 10 : 8,
          ),
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
                  color: textColor,
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
}