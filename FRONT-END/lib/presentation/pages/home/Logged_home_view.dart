import 'package:flutter/material.dart';
import 'package:kuenteco/presentation/widgets/Navbar_logged_widget.dart';
import 'package:kuenteco/presentation/widgets/Footer_widget.dart';
import 'package:kuenteco/presentation/widgets/Background_widget.dart';
import 'package:kuenteco/presentation/widgets/Create_profile_widget.dart';
import 'package:kuenteco/infrastructure/repositories/Auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/dto/AccountDetailDTO.dart';

class LoggedInHomePage extends StatelessWidget {
  final String title;
  final String? userEmail;
  final AuthRepository authRepository;

  const LoggedInHomePage({
    super.key,
    required this.title,
    this.userEmail,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AccountSelectionScreen(
        userEmail: userEmail,
        authRepository: authRepository,
      ),
    );
  }
}

class AccountSelectionScreen extends StatefulWidget {
  final String? userEmail;
  final AuthRepository authRepository;

  const AccountSelectionScreen({
    super.key,
    this.userEmail,
    required this.authRepository,
  });

  @override
  State<AccountSelectionScreen> createState() => _AccountSelectionScreenState();
}

class _AccountSelectionScreenState extends State<AccountSelectionScreen> {
  // Variables de estado
  List<AccountDetailDTO> accounts = [];
  bool isLoading = true;
  String errorMessage = '';
  String? _authToken;
  final String _baseUrl = 'API_URL/v1/account';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Métodos de inicialización
  Future<void> _initializeData() async {
    await _loadAuthToken();
    if (_authToken != null) {
      await _fetchAccounts();
    }
  }

  Future<void> _loadAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _authToken = prefs.getString('authToken');
      });

      if (_authToken == null) {
        _handleTokenError('No se encontró token de autenticación');
      }
    } catch (e) {
      _handleTokenError('Error al cargar el token: $e');
    }
  }

  // Métodos para manejar cuentas - Usando AuthRepository
  Future<void> _fetchAccounts() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Usando el método getAllAccounts del repositorio
      final result = await widget.authRepository.getAllAccounts();

      if (result.containsKey('accounts') && result['accounts'] is List) {
        _handleSuccessfulResponse(result['accounts']);
      } else if (result.containsKey('message')) {
        setState(() {
          errorMessage = result['message'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error al cargar perfiles: formato de respuesta inesperado';
          isLoading = false;
        });
      }
    } catch (e) {
      _handleFetchError(e);
    }
  }

  void _handleSuccessfulResponse(dynamic responseData) {
    if (responseData is List) {
      setState(() {
        accounts = responseData.map((json) => AccountDetailDTO.fromJson(json) as AccountDetailDTO).toList();
        isLoading = false;
      });
    } else if (responseData is Map && responseData.containsKey('message')) {
      setState(() {
        errorMessage = responseData['message'];
        isLoading = false;
      });
    }
  }

  // Métodos de manejo de errores
  void _handleTokenError(String message) {
    setState(() {
      errorMessage = message;
      isLoading = false;
    });
  }

  void _handleUnauthorizedResponse() {
    setState(() {
      errorMessage = 'Sesión expirada. Por favor inicie sesión nuevamente.';
      isLoading = false;
    });
    _handleLogout();
  }

  void _handleErrorResponse(dynamic responseData, int statusCode) {
    setState(() {
      errorMessage = responseData['message'] ?? 'Error al cargar perfiles: $statusCode';
      isLoading = false;
    });
  }

  void _handleFetchError(dynamic error) {
    setState(() {
      errorMessage = 'Error de conexión: $error';
      isLoading = false;
    });
  }

  // Métodos de autenticación
  Future<void> _handleLogout() async {
    try {
      await widget.authRepository.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  // Métodos de interacción con cuentas
  void _showCreateAccountDialog() {
    if (_authToken == null) return;

    showDialog(
      context: context,
      builder: (context) => CreateProfileWidget(
        onAccountCreated: _fetchAccounts,
        authToken: _authToken!,
        baseUrl: _baseUrl.replaceAll('/v1/account', ''),
      ),
    );
  }

  Future<void> _deleteAccount(String accountId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$accountId'),
        headers: _buildHeaders(),
      );

      if (response.statusCode == 200) {
        _showSuccessMessage('Perfil eliminado correctamente');
        await _fetchAccounts();
      } else {
        final errorData = json.decode(response.body);
        _showErrorMessage(errorData['message'] ?? 'Error al eliminar el perfil');
      }
    } catch (e) {
      _showErrorMessage('Error de conexión: $e');
    }
  }

  void _selectAccount(BuildContext context, AccountDetailDTO account) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perfil seleccionado: ${account.name}')),
    );
  }

  // Métodos de UI helpers
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showDeleteConfirmation(String accountId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount(accountId);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Construcción de la UI
  @override
  Widget build(BuildContext context) {
    return Background(
      child: Column(
        children: [
          _buildNavbar(context),
          Expanded(
            child: _buildMainContent(context),
          ),
          const Footer(),
        ],
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return KuentecoNavbar(
      currentRoute: '/loggedIn',
      onLogout: () => _handleLogout(),
      authRepository: widget.authRepository,
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(context),
            const SizedBox(height: 24),
            _buildProfileSelectionHeader(context),
            const SizedBox(height: 20),
            _buildAccountList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido de vuelta!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
            ),
            const SizedBox(height: 4),
            Text(
              widget.userEmail ?? 'Usuario@ejemplo.com',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileSelectionHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Selecciona tu perfil',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showCreateAccountDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountList(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (accounts.isEmpty) {
      return const Center(
        child: Text(
          'No hay perfiles disponibles',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: accounts.length,
      itemBuilder: (context, index) => _buildAccountCard(accounts[index], context),
    );
  }

  Widget _buildAccountCard(AccountDetailDTO account, BuildContext context) {
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
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    child:
                         ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                         )
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                account.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}