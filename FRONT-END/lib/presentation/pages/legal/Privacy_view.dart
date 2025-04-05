import 'package:flutter/material.dart';
import 'package:kuenteco/presentation/widgets/Background_widget.dart';
import 'package:kuenteco/presentation/widgets/Navbar_guest_widget.dart';
import 'package:kuenteco/presentation/widgets/Footer_widget.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  Widget _buildSection(String title, String content, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Background(
        child: Column(
          children: [
            // Navbar reutilizable
            const KuentecoNavbar(
              currentRoute: '/privacidad',
            ),

            // Contenido principal
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.05),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Center(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 800,
                                maxHeight: constraints.maxHeight * 0.65,
                              ),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.2),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Título y fecha
                                  Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Política de Privacidad',
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
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Última actualización: Marzo 5, 2025',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Contenido de la política
                                  Expanded(
                                    child: MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: ListView(
                                        physics: const BouncingScrollPhysics(),
                                        children: [
                                          _buildSection(
                                            'Información que Recopilamos',
                                            'Recopilamos información personal cuando usted se registra, utiliza nuestros servicios, o completa formularios en nuestra plataforma. Esta información puede incluir su nombre, dirección de correo electrónico, información de contacto y detalles de pago.',
                                            theme,
                                          ),
                                          _buildSection(
                                            'Cómo Utilizamos su Información',
                                            'Utilizamos la información recopilada para proporcionar, mantener y mejorar nuestros servicios, procesar transacciones, enviar notificaciones relacionadas con su cuenta, y comunicarnos con usted sobre actualizaciones o promociones.',
                                            theme,
                                          ),
                                          _buildSection(
                                            'Compartir Información',
                                            'No vendemos, intercambiamos ni transferimos su información personal a terceros sin su consentimiento, excepto cuando sea necesario para proporcionar un servicio solicitado o requerido por la ley.',
                                            theme,
                                          ),
                                          _buildSection(
                                            'Seguridad de Datos',
                                            'Implementamos medidas de seguridad diseñadas para proteger su información personal contra acceso, alteración, divulgación o destrucción no autorizados.',
                                            theme,
                                          ),
                                          _buildSection(
                                            'Sus Derechos',
                                            'Usted tiene derecho a acceder, corregir o eliminar su información personal. Si desea ejercer alguno de estos derechos, póngase en contacto con nosotros a través de los canales proporcionados.',
                                            theme,
                                          ),
                                          _buildSection(
                                            'Cambios en esta Política',
                                            'Podemos actualizar nuestra Política de Privacidad de vez en cuando. Le notificaremos cualquier cambio publicando la nueva Política de Privacidad en esta página.',
                                            theme,
                                          ),
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: colorScheme.primary,
                                                  foregroundColor: colorScheme.onPrimary,
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 32,
                                                    vertical: 12,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Entendido',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Footer reutilizable
            const Footer(),
          ],
        ),
      ),
    );
  }
}