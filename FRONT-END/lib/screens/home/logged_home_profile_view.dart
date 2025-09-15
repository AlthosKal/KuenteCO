import 'package:flutter/material.dart';
import '../../controllers/profile_controller.dart';
import '../../core/services/app/profile_service.dart';
import '../../dto/app/profile/profile_detail_dto.dart';
import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/blurred_card_widget.dart';
import '../../widgets/common/footer/footer_logged_widget.dart';
import '../../widgets/common/navbar/navbar_logged_widget.dart';
import '../../widgets/components/budget/budget_card_widget.dart';
import '../../widgets/components/category/category_card_widget.dart';
import '../../widgets/components/transaction/transaction_card_widget.dart';

class LoggedHomeProfileView extends StatefulWidget {
  final String profileName;
  final String profileImageUrl;
  
  const LoggedHomeProfileView({
    super.key,
    required this.profileName,
    required this.profileImageUrl,
  });

  /// â Factory que carga el perfil autenticado antes de mostrar la vista
  static Future<Widget> create() async {
    final profile = await ProfileService().getAuthenticatedProfile();
    return LoggedHomeProfileView(
      profileName: profile.username,
      profileImageUrl: profile.image?.imageUrl ?? '',
    );
  }

  @override
  State<LoggedHomeProfileView> createState() => _LoggedHomeProfileViewState();
}

class _LoggedHomeProfileViewState extends State<LoggedHomeProfileView> {
  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController = ProfileController();
    _profileController.loadAuthenticatedProfile();
  }

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              /// NAVBAR
              KuentecoLoggedNavbar(
                currentRoute: '/homeProfile',
                onLogout: () {
                  debugPrint('Cerrando sesión...');
                },
              ),

              /// CONTENIDO PRINCIPAL
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ValueListenableBuilder<ProfileDetailDTO?>(
                    valueListenable: _profileController.authenticatedProfile,
                    builder: (context, profile, _) {
                      if (profile == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER CON NOMBRE
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Hola, ${profile.username}!',
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
                                'Bienvenido de nuevo a Kuenteco',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),


                          /// ð² CARD CONTENEDOR GRANDE
                          BlurredCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: /// GRID DE 4 CARDS
                          GridView.builder(
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
                              }
                              return null;
                            },
                          ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          /// â FOOTER
                          const FooterLoggedWidget(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// CARD
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
