import 'package:flutter/material.dart';
import '../../core/services/app/auth_service.dart';
import '../../widgets/common/background_widget.dart';
import '../../widgets/common/blurred_card.dart';
import '../../widgets/common/footer_logged_widget.dart';
import '../../widgets/common/navbar_logged_widget.dart';
import '../../widgets/common/primary_buttom.dart';

class LoggedHomeBusinessView extends StatelessWidget {
  final String userName;
  final String profileImageUrl;

  const LoggedHomeBusinessView({
    super.key,
    required this.userName,
    required this.profileImageUrl,
  });

  /// ✅ Factory que carga el usuario autenticado antes de mostrar la vista
  static Future<Widget> create() async {
    final user = await AuthService().getAuthenticatedUser();
    return LoggedHomeBusinessView(
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
                currentRoute: '/homeBusiness',
                onLogout: () {
                  print('Cerrando sesión...');
                },
              ),

              /// ✅ CONTENIDO SCROLLABLE
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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

                          /// 🖼️ AVATAR DEL PERFIL
                          CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(profileImageUrl),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// 🔲 GRID DE 4 CARDS
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                          children: [
                            BlurredCard(
                              child: _buildCardItem(
                                icon: Icons.shopping_bag_outlined,
                                title: "Mis pedidos",
                                onTap: () {
                                  // Navegar a pedidos
                                },
                              ),
                            ),
                            BlurredCard(
                              child: _buildCardItem(
                                icon: Icons.wallet_outlined,
                                title: "Mi saldo",
                                onTap: () {
                                  // Navegar a saldo
                                },
                              ),
                            ),
                            BlurredCard(
                              child: _buildCardItem(
                                icon: Icons.local_shipping_outlined,
                                title: "Envíos",
                                onTap: () {
                                  // Navegar a envíos
                                },
                              ),
                            ),
                            BlurredCard(
                              child: _buildCardItem(
                                icon: Icons.settings_outlined,
                                title: "Configuración",
                                onTap: () {
                                  // Navegar a configuración
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// 🔵 BOTÓN PRINCIPAL
                      PrimaryButton(
                        label: "Nuevo envío",
                        isLoading: false,
                        onPressed: () {
                          // Acción rápida (crear un envío)
                        },
                      ),
                    ],
                  ),
                ),
              ),

              /// 👣 FOOTER
              const FooterLoggedWidget(),
            ],
          ),
        ),
      ),
    );
  }

  /// 🏗️ Helper para crear cada card
  Widget _buildCardItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.black87),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
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
