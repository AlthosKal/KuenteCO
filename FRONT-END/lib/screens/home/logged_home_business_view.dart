import 'package:KuenteCO/widgets/components/transaction/transaction_card_widget.dart';
import 'package:flutter/material.dart';
import '../../core/services/app/auth_service.dart';
import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/blurred_card_widget.dart';
import '../../widgets/common/footer/footer_logged_widget.dart';
import '../../widgets/common/navbar/navbar_logged_widget.dart';
import '../../widgets/components/category/category_card_widget.dart';
import '../../widgets/components/budget/budget_card_widget.dart';

class LoggedHomeBusinessView extends StatefulWidget {
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
  State<LoggedHomeBusinessView> createState() => _LoggedHomeBusinessViewState();
}

class _LoggedHomeBusinessViewState extends State<LoggedHomeBusinessView> {
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
                                "¡Hola, ${widget.userName}!",
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

                      const SizedBox(height: 20),

                      /// 🔲 CARD CONTENEDOR GRANDE
                      BlurredCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 6,
                              childAspectRatio: MediaQuery.of(context).size.width > 400 ? 3.2 : 2.8,
                            ),
                            itemBuilder: (context, index) {
                              switch (index) {
                                case 0:
                                  return const CategoryCardWidget();
                                case 1:
                                  return const BudgetCardWidget();
                                case 2:
                                  return const TransactionCardWidget(
                                    isHomeCard: true,
                                    showActions: false,
                                  );
                                case 3:
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: _buildCardItem(
                                      icon: Icons.settings_outlined,
                                      title: "Reporte",
                                      onTap: () {},
                                    ),
                                  );
                                default:
                                  return Container();
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// ✅ FOOTER
                      const FooterLoggedWidget(),
                    ],
                  ),
                ),
              ),
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
