import 'package:flutter/material.dart';

import '../../widgets/common/background_widget.dart';
import '../../widgets/common/footer_guest_widget.dart';
import '../../widgets/common/navbar_guest_widget.dart';

// Colores principales
const kPrimaryPurple = Color(0xFF890cac);
const kLightPurple = Color(0xFFEDE7F6);

class ContactView extends StatefulWidget {
  final bool isLoggedIn;

  const ContactView({
    super.key,
    this.isLoggedIn = false,
  });

  @override
  State<ContactView> createState() => _ContactoPageState();
}

class _ContactoPageState extends State<ContactView> {
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
    const formMaxWidth = 800.0;
    const formPadding = 24.0;

    return Scaffold(
      body: Background(
        child: Column(
          children: [
            KuentecoNavbar(
              currentRoute: '/contacto',
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: screenSize.height * 0.05),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: formMaxWidth,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(formPadding),
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
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Contáctanos',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Color(0xFF890cac),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Estamos aquí para ayudarte. Completa el formulario y nos pondremos en contacto contigo lo antes posible.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Color(0xFF890cac),
          ),
        ),
      ],
    );
  }

  Widget _buildContactForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildNameField()),
              const SizedBox(width: 16),
              Expanded(child: _buildEmailField()),
            ],
          ),
          const SizedBox(height: 16),
          _buildSubjectField(),
          const SizedBox(height: 16),
          _buildMessageField(),
          const SizedBox(height: 20),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return _buildTextField(
      controller: _nombreController,
      label: 'Nombre completo',
      icon: Icons.person,
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      controller: _emailController,
      label: 'Correo electrónico',
      icon: Icons.email,
      isEmail: true,
    );
  }

  Widget _buildSubjectField() {
    return _buildTextField(
      controller: _asuntoController,
      label: 'Asunto',
      icon: Icons.subject,
    );
  }

  Widget _buildMessageField() {
    return _buildTextField(
      controller: _mensajeController,
      label: 'Mensaje',
      icon: Icons.message,
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 5,
      ),
      child: const Text(
        'Enviar mensaje',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildContactInfoItem(
            icon: Icons.email,
            text: 'soporte@kuenteco.com',
          ),
          _buildContactInfoItem(
            icon: Icons.phone,
            text: '+52 (123) 456-7890',
          ),
          _buildContactInfoItem(
            icon: Icons.access_time,
            text: 'Lun-Vie: 9:00 AM - 6:00 PM',
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoItem({
    required IconData icon,
    required String text,
  }) {
    return Tooltip(
      message: text,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Color(0xFF890cac), size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Color(0xFF890cac),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es requerido';
        }
        if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Ingrese un email válido';
        }
        return null;
      },
      style: TextStyle(color: Color(0xFF890cac)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF890cac)),
        prefixIcon: Icon(icon, color: Color(0xFF890cac)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF890cac)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF890cac), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '¡Mensaje enviado correctamente!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: kPrimaryPurple,
          duration: const Duration(seconds: 3),
        ),
      );
      _nombreController.clear();
      _emailController.clear();
      _asuntoController.clear();
      _mensajeController.clear();
    }
  }
}