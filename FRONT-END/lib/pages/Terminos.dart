import 'package:flutter/material.dart';
import 'package:kuenteco/widgets/navbar.dart';
import 'package:kuenteco/widgets/footer.dart';

class TerminosPage extends StatelessWidget {
  final bool isLoggedIn;

  const TerminosPage({super.key, this.isLoggedIn = false});

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
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
    // Colores utilizados
    const Color primaryColor = Color(0xFF890cac);
    const Color whiteColor = Colors.white;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor, // Morado arriba
              whiteColor,   // Blanco abajo
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Usar el navbar reutilizable
              KuentecoNavbar(
                currentRoute: '/terminos',
                isLoggedIn: isLoggedIn,
              ),

              // Contenido de la página de términos
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Espacio superior
                          SizedBox(height: constraints.maxHeight * 0.05),

                          // Contenedor principal
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
                                  color: whiteColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: whiteColor.withOpacity(0.3), width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.2),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Título y fecha de actualización
                                    Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            'Términos y Condiciones de Uso',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: whiteColor,
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
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: whiteColor.withOpacity(0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Contenido de los términos y condiciones
                                    Expanded(
                                      child: MediaQuery.removePadding(
                                        context: context,
                                        removeTop: true,
                                        child: ListView(
                                          physics: const BouncingScrollPhysics(),
                                          children: [
                                            _buildSection(
                                              'Aceptación de los Términos',
                                              'Al acceder y utilizar Kuenteco, usted acepta estar sujeto a estos Términos y Condiciones de Uso. Si no está de acuerdo con alguno de los términos, no podrá acceder ni utilizar nuestros servicios.',
                                            ),
                                            _buildSection(
                                              'Uso del Servicio',
                                              'Nuestros servicios están diseñados para ser utilizados de manera legal y de acuerdo con estas condiciones. Usted se compromete a no utilizar nuestros servicios para fines ilegales o prohibidos por estas condiciones.',
                                            ),
                                            _buildSection(
                                              'Cuentas de Usuario',
                                              'Al registrarse en Kuenteco, es responsable de mantener la confidencialidad de su cuenta y contraseña. Usted es responsable de todas las actividades que ocurran bajo su cuenta.',
                                            ),
                                            _buildSection(
                                              'Cambios en los Términos',
                                              'Nos reservamos el derecho de modificar estos términos en cualquier momento. Los cambios entrarán en vigor inmediatamente después de su publicación. El uso continuado de nuestros servicios después de cualquier cambio constituye su aceptación de los nuevos términos.',
                                            ),
                                            _buildSection(
                                              'Ley Aplicable',
                                              'Estos términos y condiciones se regirán e interpretarán de acuerdo con las leyes vigentes, sin tener en cuenta sus disposiciones sobre conflicto de leyes.',
                                            ),

                                            // Botón de aceptar
                                            Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: primaryColor,
                                                    foregroundColor: whiteColor,
                                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
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
            ],
          ),
        ),
      ),
      // Usando el Footer reutilizable
      bottomNavigationBar: const Footer(),
    );
  }
}