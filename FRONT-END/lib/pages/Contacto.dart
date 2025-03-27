import 'package:flutter/material.dart';
import 'package:kuenteco/widgets/navbar.dart';
import 'package:kuenteco/widgets/footer.dart';

class ContactoPage extends StatefulWidget {
  final Color backgroundColor;
  final bool isLoggedIn;

  const ContactoPage({
    super.key,
    this.backgroundColor = const Color(0xFF890cac),
    this.isLoggedIn = false,
  });

  @override
  State<ContactoPage> createState() => _ContactoPageState();
}

class _ContactoPageState extends State<ContactoPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _asuntoController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
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
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF890cac),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              KuentecoNavbar(
                currentRoute: '/contacto',
                isLoggedIn: widget.isLoggedIn,
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
                              maxWidth: 800,
                              maxHeight: screenSize.height * 0.65,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Contáctanos',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Estamos aquí para ayudarte. Completa el formulario y nos pondremos en contacto contigo lo antes posible.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: _buildTextField(
                                                    controller: _nombreController,
                                                    label: 'Nombre completo',
                                                    icon: Icons.person,
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Por favor ingresa tu nombre';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: _buildTextField(
                                                    controller: _emailController,
                                                    label: 'Correo electrónico',
                                                    icon: Icons.email,
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Por favor ingresa tu email';
                                                      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                                        return 'Por favor ingresa un email válido';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            _buildTextField(
                                              controller: _asuntoController,
                                              label: 'Asunto',
                                              icon: Icons.subject,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Por favor ingresa el asunto';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            _buildTextField(
                                              controller: _mensajeController,
                                              label: 'Mensaje',
                                              icon: Icons.message,
                                              maxLines: 3,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Por favor ingresa tu mensaje';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (_formKey.currentState!.validate()) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('¡Mensaje enviado correctamente!'),
                                                        backgroundColor: Color(0xFF890cac),
                                                        duration: Duration(seconds: 3),
                                                      ),
                                                    );
                                                    _nombreController.clear();
                                                    _emailController.clear();
                                                    _asuntoController.clear();
                                                    _mensajeController.clear();
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF8A2BE2),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Enviar mensaje',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  _buildCompactContactInfo(
                                                    icon: Icons.email,
                                                    info: 'soporte@kuenteco.com',
                                                    iconColor: const Color(0xFF890cac),
                                                    textColor: const Color(0xFF890cac),
                                                  ),
                                                  _buildCompactContactInfo(
                                                    icon: Icons.phone,
                                                    info: '+52 (123) 456-7890',
                                                    iconColor: const Color(0xFF890cac),
                                                    textColor: const Color(0xFF890cac),
                                                  ),
                                                  _buildCompactContactInfo(
                                                    icon: Icons.access_time,
                                                    info: 'Lun-Vie: 9:00-18:00',
                                                    iconColor: const Color(0xFF890cac),
                                                    textColor: const Color(0xFF890cac),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
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

  Widget _buildCompactContactInfo({
    required IconData icon,
    required String info,
    Color iconColor = Colors.white,
    Color textColor = Colors.white,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Text(
          info,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}