import 'package:flutter/material.dart';
import '../../core/services/app/auth_service.dart';
import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/blurred_card_widget.dart';
import '../../widgets/common/footer/footer_logged_widget.dart';
import '../../widgets/common/navbar/navbar_logged_widget.dart';
import '../../widgets/components/category/category_card_widget.dart';
import '../../widgets/components/budget/budget_card_widget.dart';
import '../../widgets/components/transaction/transaction_card_widget.dart';
import '../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';

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
                  padding: const EdgeInsets.all(8),
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
                      const SizedBox(height: 8),

                      /// ✅ GRID DE 4 CARDS AJUSTADOS
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 1.5,
                        ),
                        itemBuilder: (context, index) {
                          switch (index) {
                            case 0:
                              return const CategoryCardWidget();
                            case 1:
                              return const BudgetCardWidget();
                            case 2:
                              return BlurredCard(
                                child: TransactionCardWidget(
                                  transaction: TransactionDetailDTO(
                                    id: 0,
                                    name: 'Transacciones',
                                    amount: 0,
                                    date: DateTime.now().toIso8601String(),
                                    description: 'Ver todas las transacciones',
                                  ),
                                  showActions: false,
                                  onTap: () {
                                    Navigator.pushNamed(context, '/transactions');
                                  },
                                ),
                              );
                            case 3:
                              return BlurredCard(
                                child: _buildCardItem(
                                  icon: Icons.settings_outlined,
                                  title: "Configuración",
                                  onTap: () {},
                                ),
                              );
                            default:
                              return Container();
                          }
                        },
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
