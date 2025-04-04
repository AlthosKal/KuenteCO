import 'package:flutter/material.dart';
import 'package:kuenteco/widgets/Navbar_logged_widget.dart';
import 'package:kuenteco/widgets/Footer_widget.dart';
import 'package:kuenteco/widgets/Background_widget.dart';
import 'Profiles_view.dart'; // Make sure this import path is correct

class LoggedInHomePage extends StatelessWidget {
  final String title;
  final String? userEmail;

  const LoggedInHomePage({
    super.key,
    required this.title,
    this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Column(
          children: [
            _buildNavbar(context),
            Expanded(
              child: Center(
                child: _buildWelcomeCard(context),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return KuentecoNavbar(
      currentRoute: '/loggedIn',
      onLogout: () => _handleLogout(context),
    );
  }

  void _handleLogout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUserAvatar(colorScheme),
          const SizedBox(height: 15),
          _buildWelcomeText(theme),
          const SizedBox(height: 10),
          _buildUserEmailText(),
          const SizedBox(height: 20),
          _buildDescriptionText(),
          const SizedBox(height: 20),
          _buildDashboardButton(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(ColorScheme colorScheme) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person,
        size: 40,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildWelcomeText(ThemeData theme) {
    return Text(
      '¡Bienvenido de vuelta!',
      style: theme.textTheme.headlineMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildUserEmailText() {
    return Text(
      userEmail ?? 'Usuario@ejemplo.com',
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDescriptionText() {
    return const Text(
      'Estás listo para continuar gestionando tus finanzas personales.\n'
          'Revisa tus últimos movimientos o explora nuevas herramientas\n'
          'para optimizar tu economía.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, ColorScheme colorScheme) {
    return ElevatedButton(
      onPressed: () => _navigateToProfiles(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      ),
      child: const Text(
        'Ver perfiles',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  void _navigateToProfiles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountSelectionScreen(),
      ),
    ).then((selectedAccount) {
      if (selectedAccount != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil seleccionado: ${selectedAccount.name}')),
        );
      }
    });
  }
}