import 'package:flutter/material.dart';
import 'package:kuenteco/infrastructure/repositories/Auth_repository.dart';
import 'package:kuenteco/presentation/widgets/Navbar_logged_widget.dart';

class AccountHomeView extends StatelessWidget {
  final AuthRepository authRepository;
  final VoidCallback onLogout;

  const AccountHomeView({
    super.key,
    required this.authRepository,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8A2BE2),
      body: SafeArea(
        child: Column(
          children: [
            // Navbar personalizado
            KuentecoNavbar(
              currentRoute: '/account_home_view',
              onLogout: onLogout,
              authRepository: authRepository,
            ),

            // Encabezado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '¡Bienvenido/a, Usuario!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Miércoles, 19 de marzo de 2025',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Cuerpo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.2,
                  children: [
                    _buildTotalBudgetCard(),
                    _buildFinancialGoalsCard(),
                    _buildRecentTransactionsCard(),
                    _buildAlertsCard(),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                '© 2025 Kuenteco    Todos los derechos reservados',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBudgetCard() {
    return _buildCard(
      children: const [
        Text(
          'Presupuesto total de la cuenta',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10),
        Text(
          '\$300,000',
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          'Actualizado hoy a las 20:50',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFinancialGoalsCard() {
    return _buildCard(
      children: [
        const Text(
          'Metas Financieras',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 15),
        _buildGoalProgress('Alimentación', 5000, 10000),
        const SizedBox(height: 10),
        _buildGoalProgress('Transporte', 15000, 20000),
        const SizedBox(height: 10),
        _buildGoalProgress('Vacaciones', 10000, 50000),
      ],
    );
  }

  Widget _buildGoalProgress(String name, int current, int total) {
    final double progress = current / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.pink.shade300,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text('\$${current.toString()}/\$${total.toString()}',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsCard() {
    return _buildCard(
      children: [
        const Text(
          'Movimientos Recientes',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        _buildTransactionItem('Supermercado', 'Hoy, 22:00 PM', -5000),
        _buildTransactionItem('Salario', '18 Mar, 8:00 AM', 220000),
        _buildTransactionItem('Ahorro', 'Hoy, 20:00 PM', 100000),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String date, int amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              Text(date, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          Text(
            '${amount > 0 ? '+' : ''}\$${amount.abs().toString()}',
            style: TextStyle(
              color: amount > 0 ? Colors.green : Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsCard() {
    return _buildCard(
      children: const [
        Text(
          'Alertas y Notificaciones',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10),
        Text(
          'Presupuesto de Comida está al 85% con 10 días restantes',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        Divider(color: Colors.white30),
        SizedBox(height: 10),
        Text(
          'Pago de Netflix programado para mañana (\$14,599)',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        Divider(color: Colors.white30),
        SizedBox(height: 10),
        Text(
          '¡Has ahorrado \$500 este mes! Mejor que el mes pasado.',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }
}
