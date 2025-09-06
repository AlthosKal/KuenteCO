import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/footer/footer_logged_widget.dart';
import '../../widgets/common/navbar/navbar_logged_widget.dart';

// ð¨ Colores principales
const kPrimaryPurple = Color(0xFF890cac);
const kLightPurple = Color(0xFFEDE7F6);

class ContactLoggedView extends StatefulWidget {
  final bool isLoggedIn;

  const ContactLoggedView({
    super.key,
    this.isLoggedIn = false,
  });

  @override
  State<ContactLoggedView> createState() => _ContactLoggedViewState();
}

class _ContactLoggedViewState extends State<ContactLoggedView> {
  // ð¯ Controladores de formulario
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _asuntoController = TextEditingController();
  final _mensajeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _asuntoController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Background(
        child: Column(
          children: [
            /// â Navbar de usuario logueado
            KuentecoLoggedNavbar(
              currentRoute: AppRoutes.contactLogged,
              onLogout: () {},
            ),

            /// â Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: screenSize.height * 0.05),
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
                                _buildHeaderSection(theme),
                                const SizedBox(height: 24),
                                _buildContactForm(theme),
                                const SizedBox(height: 24),
                                _buildContactInfoSection(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// â Footer
            const FooterLoggedWidget(),
          ],
        ),
      ),
    );
  }

  /// ð·ï¸ Encabezado
  Widget _buildHeaderSection(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Contáctanos',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: kPrimaryPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Estamos aquí para ayudarte. Completa el formulario y nos pondremos en contacto contigo lo antes posible.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: kPrimaryPurple,
          ),
        ),
      ],
    );
  }

  /// ð© Formulario de contacto
  Widget _buildContactForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTextField(_nombreController, 'Nombre completo', Icons.person)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_emailController, 'Correo electrónico', Icons.email, isEmail: true)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(_asuntoController, 'Asunto', Icons.subject),
          const SizedBox(height: 16),
          _buildTextField(_mensajeController, 'Mensaje', Icons.message, maxLines: 3),
          const SizedBox(height: 20),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  /// ð¬ Campos del formulario
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
        bool isEmail = false,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Este campo es requerido';
        if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Ingrese un email válido';
        }
        return null;
      },
      style: const TextStyle(color: kPrimaryPurple),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kPrimaryPurple),
        prefixIcon: Icon(icon, color: kPrimaryPurple),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kPrimaryPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kPrimaryPurple, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  /// ð¤ BotÃ³n para enviar el mensaje
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 5,
      ),
      child: const Text(
        'Enviar mensaje',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  /// ð InformaciÃ³n de contacto
  Widget _buildContactInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildContactInfoItem(Icons.email, 'soporte@kuenteco.com'),
          _buildContactInfoItem(Icons.phone, '+57 (123) 456-7890'),
          _buildContactInfoItem(Icons.access_time, 'Lun-Vie: 9:00 AM - 6:00 PM'),
        ],
      ),
    );
  }

  Widget _buildContactInfoItem(IconData icon, String text) {
    return Tooltip(
      message: text,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kPrimaryPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(color: kPrimaryPurple, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /// ð¥ Enviar formulario
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Mensaje enviado correctamente!', style: TextStyle(color: Colors.white)),
          backgroundColor: kPrimaryPurple,
          duration: Duration(seconds: 3),
        ),
      );

      _nombreController.clear();
      _emailController.clear();
      _asuntoController.clear();
      _mensajeController.clear();
    }
  }
}
