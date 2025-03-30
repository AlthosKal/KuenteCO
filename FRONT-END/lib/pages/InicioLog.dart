import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:kuenteco/widgets/navbarlog.dart';
import 'package:kuenteco/widgets/footer.dart';

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
      body: _buildBody(context),
      bottomNavigationBar: const Footer(),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: _buildBackgroundDecoration(),
      child: SafeArea(
        child: Column(
          children: [
            _buildNavbar(context),
            Expanded(
              child: Center(
                child: _buildWelcomeCard(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF890cac), Colors.white],
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return KuentecoNavbar(
      currentRoute: '/loggedIn',
      isLoggedIn: true,
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
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: _buildCardDecoration(),
          child: _buildCardContent(context),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF890cac).withOpacity(0.2),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ],
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildUserAvatar(),
        const SizedBox(height: 15),
        _buildWelcomeText(),
        const SizedBox(height: 10),
        _buildUserEmailText(),
        const SizedBox(height: 20),
        _buildDescriptionText(),
        const SizedBox(height: 20),
        _buildDashboardButton(context),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return const CircleAvatar(
      radius: 40,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person,
        size: 40,
        color: Color(0xFF890cac),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Text(
      '¡Bienvenido de vuelta!',
      style: TextStyle(
        fontSize: 28,
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

  Widget _buildDashboardButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _navigateToDashboard(context),
      style: _dashboardButtonStyle(),
      child: const Text(
        'Ir a mi Dashboard',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  ButtonStyle _dashboardButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF890cac),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
    );
  }

  void _navigateToDashboard(BuildContext context) {
    Navigator.pushNamed(context, '/dashboard');
  }
}