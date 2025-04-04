import 'package:flutter/material.dart';
import 'package:kuenteco/widgets/Navbar_logged_widget.dart';
import 'package:kuenteco/widgets/Footer_widget.dart';
import 'package:kuenteco/widgets/Background_widget.dart';
import 'package:kuenteco/widgets/Create_profile_widget.dart';
import 'package:kuenteco/widgets/Delete_profile_widget.dart';
import 'package:kuenteco/models/account_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class LoggedInHomePage extends StatelessWidget {
  final String title;
  final String? userEmail;

  const LoggedInHomePage({
    super.key,
    required this.title,
    this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AccountSelectionScreen(
        userEmail: userEmail,
        showWelcomeSection: true,
      ),
    );
  }
}

class AccountSelectionScreen extends StatefulWidget {
  final String? userEmail;
  final bool showWelcomeSection;

  const AccountSelectionScreen({
    Key? key,
    this.userEmail,
    this.showWelcomeSection = false,
  }) : super(key: key);

  @override
  State<AccountSelectionScreen> createState() => _AccountSelectionScreenState();
}

class _AccountSelectionScreenState extends State<AccountSelectionScreen> {
  List<Account> accounts = [];
  bool isLoading = true;
  String errorMessage = '';
  String? _authToken;
  final String _baseUrl = 'https://your-api-base-url.com/api/v1'; // Update with your actual base URL

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchAccounts();
  }

  Future<void> _loadTokenAndFetchAccounts() async {
    await _loadAuthToken();
    await fetchAccounts();
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('authToken');
    });

    if (_authToken == null) {
      setState(() {
        errorMessage = 'No authentication token found. Please log in again.';
        isLoading = false;
      });
      // Optionally navigate to login page
      // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> fetchAccounts() async {
    if (_authToken == null) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          accounts = data.map((json) => Account.fromJson(json)).toList();
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Token might be expired or invalid
        setState(() {
          errorMessage = 'Session expired. Please log in again.';
          isLoading = false;
        });
        _handleLogout(context);
      } else {
        setState(() {
          errorMessage = 'Error loading profiles: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Connection error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Call logout API if token exists
      if (_authToken != null) {
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {
            'Authorization': 'Bearer $_authToken',
          },
        );
      }

      // Clear stored token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');

      // Navigate to login page
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
      );
    } catch (e) {
      // Even if logout API fails, clear token and navigate
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Column(
        children: [
          _buildNavbar(context),
          Expanded(
            child: SingleChildScrollView(
              child: _buildMainContent(context),
            ),
          ),
          const Footer(),
        ],
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return KuentecoNavbar(
      currentRoute: '/loggedIn',
      onLogout: () => _handleLogout(context),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserAvatar(colorScheme),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeText(theme),
                  const SizedBox(height: 4),
                  _buildUserEmailText(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Center(
            child: Column(
              children: [
                Text(
                  'Selecciona tu perfil',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _showCreateAccountDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage.isNotEmpty)
            Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            )
          else if (accounts.isEmpty)
              const Center(
                child: Text(
                  'No hay perfiles disponibles',
                  style: TextStyle(color: Colors.white),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return _buildAccountCard(account, context);
                },
              ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(ColorScheme colorScheme) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person,
        size: 30,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildWelcomeText(ThemeData theme) {
    return Text(
      '¡Bienvenido de vuelta!',
      style: theme.textTheme.headlineSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildUserEmailText() {
    return Text(
      widget.userEmail ?? 'Usuario@ejemplo.com',
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildAccountCard(Account account, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectAccount(context, account),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primary.withOpacity(0.2),
                    child: account.image.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(account.image),
                    )
                        : Text(
                      account.name[0].toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red.shade300),
                    onPressed: () => _showDeleteConfirmation(account),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                account.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                account.description,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectAccount(BuildContext context, Account account) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perfil seleccionado: ${account.name}')),
    );
  }

  Future<void> _showDeleteConfirmation(Account account) async {
    if (_authToken == null) return;

    showDialog(
      context: context,
      builder: (context) => DeleteProfileWidget(
        account: account,
        onDeleteConfirmed: () async {
          try {
            final response = await http.delete(
              Uri.parse('$_baseUrl/account/${account.id}'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_authToken',
              },
            );

            if (response.statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perfil eliminado correctamente')),
              );
              await fetchAccounts();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al eliminar: ${response.statusCode}')),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error de conexión: $e')),
            );
          }
        },
      ),
    );
  }

  void _showCreateAccountDialog(BuildContext context) {
    if (_authToken == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: CreateProfileWidget(
          onAccountCreated: () async {
            Navigator.pop(context);
            await fetchAccounts();
          },
          authToken: _authToken!,
          baseUrl: _baseUrl,
        ),
      ),
    );
  }
}