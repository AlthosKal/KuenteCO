import 'package:flutter/material.dart';
import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/footer/footer_logged_widget.dart';
import '../../widgets/common/navbar/navbar_logged_widget.dart';

// 🎨 Colores principales
const kPrimaryPurple = Color(0xFF890cac);
const kLightPurple = Color(0xFFEDE7F6);

class PrivacyLoggedView extends StatelessWidget {
  const PrivacyLoggedView({super.key});

  /// 🔹 Construcción de cada sección de la política
  Widget _buildSection(String title, String content, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: kPrimaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: kPrimaryPurple.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: kPrimaryPurple.withOpacity(0.3)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Background(
        child: Column(
          children: [
            /// ✅ Navbar de usuario logueado
            KuentecoLoggedNavbar(
              currentRoute: '/privacy', // 🔥 CORREGIDO: antes estaba '/privacidad'
              onLogout: () {
                print('Usuario cerró sesión desde Privacy');
              },
            ),

            /// ✅ Contenido
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: screenSize.height * 0.05),

                    /// 📦 Contenedor principal
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: kLightPurple.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: kPrimaryPurple.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// 📌 Encabezado
                                Column(
                                  children: [
                                    Text(
                                      'Política de Privacidad',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: kPrimaryPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Última actualización: Marzo 5, 2025',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: kPrimaryPurple.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                /// 📜 Contenido de la política
                                MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            /// ✅ Footer
            const FooterLoggedWidget(),
          ],
        ),
      ),
    );
  }
}
