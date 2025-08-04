import 'package:flutter/material.dart';
import '../../widgets/common/background_widget.dart';
import '../../widgets/common/footer_logged_widget.dart';
import '../../widgets/common/navbar_logged_widget.dart';

// 🎨 Colores principales
const kPrimaryPurple = Color(0xFF890cac);
const kLightPurple = Color(0xFFEDE7F6);

class TermsLoggedView extends StatelessWidget {
  const TermsLoggedView({super.key});

  /// 🔹 Construcción de cada sección de los términos
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
              currentRoute: '/terms', // 🔥 CORREGIDO (antes '/terminos')
              onLogout: () {
                print('Usuario cerró sesión desde Terms');
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
                                      'Términos y Condiciones de Uso',
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

                                /// 📜 Contenido de los términos
                                MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: [
                                      _buildSection(
                                        'Aceptación de los Términos',
                                        'Al acceder y utilizar Kuenteco, usted acepta estar sujeto a estos Términos y Condiciones de Uso. Si no está de acuerdo con alguno de los términos, no podrá acceder ni utilizar nuestros servicios.',
                                        theme,
                                      ),
                                      _buildSection(
                                        'Uso del Servicio',
                                        'Nuestros servicios están diseñados para ser utilizados de manera legal y de acuerdo con estas condiciones. Usted se compromete a no utilizar nuestros servicios para fines ilegales o prohibidos por estas condiciones.',
                                        theme,
                                      ),
                                      _buildSection(
                                        'Cuentas de Usuario',
                                        'Al registrarse en Kuenteco, es responsable de mantener la confidencialidad de su cuenta y contraseña. Usted es responsable de todas las actividades que ocurran bajo su cuenta.',
                                        theme,
                                      ),
                                      _buildSection(
                                        'Cambios en los Términos',
                                        'Nos reservamos el derecho de modificar estos términos en cualquier momento. Los cambios entrarán en vigor inmediatamente después de su publicación. El uso continuado de nuestros servicios después de cualquier cambio constituye su aceptación de los nuevos términos.',
                                        theme,
                                      ),
                                      _buildSection(
                                        'Ley Aplicable',
                                        'Estos términos y condiciones se regirán e interpretarán de acuerdo con las leyes vigentes, sin tener en cuenta sus disposiciones sobre conflicto de leyes.',
                                        theme,
                                      ),

                                      /// ✅ Botón de "Aceptar Términos"
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              // ✅ OPCIÓN 2: Cambiar a:
                                              // Navigator.pushReplacementNamed(context, AppRoutes.homePersonal);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kPrimaryPurple,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 32,
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              elevation: 5,
                                            ),
                                            child: const Text(
                                              'Aceptar Términos',
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
