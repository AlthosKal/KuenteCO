import 'package:flutter/material.dart';
import '../../core/services/app/auth_service.dart';
import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/blurred_card_widget.dart';
import '../../widgets/common/footer/footer_logged_widget.dart';
import '../../widgets/common/navbar/navbar_logged_widget.dart';
import '../../widgets/common/category/category_card_widget.dart';

class LoggedHomePersonalView extends StatelessWidget {
  final String userName;
  final String profileImageUrl;

  const LoggedHomePersonalView({
    super.key,
    required this.userName,
    required this.profileImageUrl,
  });

  /// ✅ Factory que carga el usuario autenticado antes de mostrar la vista
  static Future<Widget> create() async {
    final user = await AuthService().getAuthenticatedUser();
    return LoggedHomePersonalView(
      userName: user.username,
      profileImageUrl: user.image?.imageUrl ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              /// ✅ NAVBAR ARRIBA
              KuentecoLoggedNavbar(
                currentRoute: '/homePersonal',
                onLogout: () {
                  print('Cerrando sesión...');
                },
              ),

              /// ✅ CONTENIDO PRINCIPAL
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🏷️ HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "¡Hola, $userName!",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Bienvenido de nuevo a Kuenteco",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      /// ✅ GRID DE 4 CARDS AJUSTADOS
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.1,
                          children: [
                            // 📋 Card de Categorías (reemplaza Mis pedidos)
                            const CategoryCardWidget(),
                            BlurredCard(
                              child: _buildCardItem(
                                icon: Icons.wallet_outlined,
                                title: "Mi saldo",
                                onTap: () {},
                              ),
                            ),
                            BlurredCard(
                              child: _buildCardItem(
                                icon: Icons.local_shipping_outlined,
                                title: "Envíos",
                                onTap: () {},
                              ),
                            ),
                            BlurredCard(
                              child: _buildCardItem(
                                icon: Icons.settings_outlined,
                                title: "Configuración",
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// ✅ FOOTER ABAJO
              const FooterLoggedWidget(),
            ],
          ),
        ),
      ),
    );
  }

  /// 🏗️ CARD PEQUEÑO
  Widget _buildCardItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
