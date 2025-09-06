import 'package:flutter/material.dart';

import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/footer/footer_logged_widget.dart';
import '../../widgets/common/navbar/navbar_logged_widget.dart';

// ð¨ Colores principales
const kPrimaryPurple = Color(0xFF890cac);
const kLightPurple = Color(0xFFEDE7F6);

class PrivacyLoggedView extends StatelessWidget {
  const PrivacyLoggedView({super.key});

  /// ð¹ ConstrucciÃ³n de cada secciÃ³n de la polÃ­tica
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
            /// â Navbar de usuario logueado
            KuentecoLoggedNavbar(
              currentRoute: '/privacy', // ð¥ CORREGIDO: antes estaba '/privacidad'
              onLogout: () {
                print('Usuario cerrÃ³ sesiÃ³n desde Privacy');
              },
            ),

            /// â Contenido
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: screenSize.height * 0.05),

                    /// ð¦ Contenedor principal
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
                                /// ð Encabezado
                                Column(
                                  children: [
                                    Text(
                                      'PolÃ­tica de Privacidad',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: kPrimaryPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Ãltima actualizaciÃ³n: Marzo 5, 2025',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: kPrimaryPurple.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                /// ð Contenido de la polÃ­tica
                                MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: [
                                      _buildSection(
                                        'InformaciÃ³n que Recopilamos',
                                        'Recopilamos informaciÃ³n personal cuando usted se registra, utiliza nuestros servicios, o completa formularios en nuestra plataforma. Esta informaciÃ³n puede incluir su nombre, direcciÃ³n de correo electrÃ³nico, informaciÃ³n de contacto y detalles de pago.',
                                        theme,
                                      ),
                                      _buildSection(
                                        'CÃ³mo Utilizamos su InformaciÃ³n',
                                        'Utilizamos la informaciÃ³n recopilada para proporcionar, mantener y mejorar nuestros servicios, procesar transacciones, enviar notificaciones relacionadas con su cuenta, y comunicarnos con usted sobre actualizaciones o promociones.',
                                        theme,
                                      ),
                                      _buildSection(
                                        'Compartir InformaciÃ³n',
                                        'No vendemos, intercambiamos ni transferimos su informaciÃ³n personal a terceros sin su consentimiento, excepto cuando sea necesario para proporcionar un servicio solicitado o requerido por la ley.',
                                        theme,
                                      ),
                                      _buildSection(
                                        'Seguridad de Datos',
                                        'Implementamos medidas de seguridad diseÃ±adas para proteger su informaciÃ³n personal contra acceso, alteraciÃ³n, divulgaciÃ³n o destrucciÃ³n no autorizados.',
                                        theme,
                                      ),
                                      _buildSection(
                                        'Sus Derechos',
                                        'Usted tiene derecho a acceder, corregir o eliminar su informaciÃ³n personal. Si desea ejercer alguno de estos derechos, pÃ³ngase en contacto con nosotros a travÃ©s de los canales proporcionados.',
                                        theme,
                                      ),
                                      _buildSection(
                                        'Cambios en esta PolÃ­tica',
                                        'Podemos actualizar nuestra PolÃ­tica de Privacidad de vez en cuando. Le notificaremos cualquier cambio publicando la nueva PolÃ­tica de Privacidad en esta pÃ¡gina.',
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

            /// â Footer
            const FooterLoggedWidget(),
          ],
        ),
      ),
    );
  }
}
