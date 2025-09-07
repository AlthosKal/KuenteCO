import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';

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

  /// ð± Layout para pantallas pequeñas
  Widget _buildMobileLayout(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildLogo(context, true),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildAuthButtons(context),
      ),
    ],
  );

  /// ð» Layout para pantallas grandes
  Widget _buildDesktopLayout(BuildContext context) => Row(
    children: [
      _buildLogo(context, false),
      const Spacer(),
      Row(children: _buildAuthButtons(context)),
    ],
  );

  /// ð Botones de login / register
  List<Widget> _buildAuthButtons(BuildContext context) => [
    _buildButton(
      context,
      'Iniciar sesión',
      AppRoutes.login,
      textColor: const Color(0xFF890cac),
    ),
    const SizedBox(width: 12),
    _buildButton(
      context,
      'Registrarse',
      AppRoutes.register,
      backgroundColor: const Color(0xFF890cac),
      width: 150,
    ),
  ];

  /// Logo que lleva al home
  Widget _buildLogo(BuildContext context, bool isSmallScreen) {
    final defaultWidth = isSmallScreen ? 220.0 : 250.0;
    final defaultHeight = isSmallScreen ? 55.0 : 62.5;
    final width = logoWidth ?? defaultWidth;
    final height = useDefaultLogoSize ? null : (logoHeight ?? defaultHeight);

    return GestureDetector(
      onTap: () {
        if (currentRoute != '/') {
          Navigator.pushReplacementNamed(context, '/');
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Image.asset(
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
        ),
      ),
    );
  }

  /// ð Construye cualquier botón del navbar (incluye login y register)
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
        onTap: () {
          if (route != currentRoute) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
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