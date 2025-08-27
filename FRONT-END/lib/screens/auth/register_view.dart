import 'package:flutter/material.dart';
import '../../controllers/register_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/enum/user_type_enum.dart';
import '../../widgets/common/background/animated_background_scaffold_widget.dart';
import '../../widgets/common/blurred_card_widget.dart';
import '../../widgets/common/buttoms/primary_buttom_widget.dart';
import '../../widgets/common/form/custom_form_widget.dart';
import '../../widgets/common/form/email_form_widget.dart';
import '../../widgets/common/form/form_title_text_widget.dart';
import '../../widgets/common/form/password_form_widget.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedBackgroundScaffold(child: RegisterForm());
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _registerController = RegisterController();

  // Campos de texto
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // FocusNodes
  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  /// ✅ Estado del tipo de cuenta usando enum
  final ValueNotifier<UserType> _selectedUserType =
  ValueNotifier<UserType>(UserType.PERSONAL);

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _registerController.dispose();
    _selectedUserType.dispose();
    super.dispose();
  }

  void _submitRegister() {
    if (!_formKey.currentState!.validate()) return;

    _registerController.register(
      context: context,
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      type: _selectedUserType.value, // ✅ Se envía el enum al controller
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return BlurredCard(
      width: isSmallScreen ? 360.0 : 400.0,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            FormTitleText(text: 'Registro'),
            const SizedBox(height: 20),

            /// 📌 Nombre Completo
            CustomFormField(
              controller: _usernameController,
              focusNode: _usernameFocusNode,
              labelText: 'Usuario',
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: (value) =>
              value == null || value.isEmpty ? 'Campo requerido' : null,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_emailFocusNode);
              },
            ),
            const SizedBox(height: 12),

            /// 📌 Email
            EmailFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
            ),
            const SizedBox(height: 12),

            /// 📌 Contraseña
            ValueListenableBuilder<bool>(
              valueListenable: _registerController.obscurePassword,
              builder: (context, obscure, _) {
                return PasswordFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context)
                        .requestFocus(_confirmPasswordFocusNode);
                  },
                );
              },
            ),

            /// 📌 Confirmar Contraseña
            ValueListenableBuilder<bool>(
              valueListenable: _registerController.obscurePassword,
              builder: (context, obscure, _) {
                return PasswordFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  labelText: 'Confirmar Contraseña',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            /// 🔥 Selector de tipo de cuenta
            const Text(
              'Tipo de cuenta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            ValueListenableBuilder<UserType>(
              valueListenable: _selectedUserType,
              builder: (context, selected, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAccountTypeButton(
                      label: 'Personal',
                      icon: Icons.person,
                      isSelected: selected == UserType.PERSONAL,
                      onTap: () => _selectedUserType.value = UserType.PERSONAL,
                    ),
                    const SizedBox(width: 10),
                    _buildAccountTypeButton(
                      label: 'Negocio',
                      icon: Icons.store,
                      isSelected: selected == UserType.BUSINESS,
                      onTap: () => _selectedUserType.value = UserType.BUSINESS,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            /// 📌 Botón de registrar
            ValueListenableBuilder(
              valueListenable: _registerController.isLoading,
              builder: (context, isLoading, _) {
                return isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : PrimaryButton(
                  label: 'Registrar',
                  onPressed: _submitRegister,
                );
              },
            ),
            const SizedBox(height: 12),

            /// 📌 Botón para volver a login
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              child: const Text.rich(
                TextSpan(
                  text: '¿Ya tienes una cuenta? ',
                  style: TextStyle(color: Colors.white),
                  children: [
                    TextSpan(
                      text: 'Inicia Sesión',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎨 Botón custom para Personal / Negocio
  Widget _buildAccountTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.purple : Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.purple : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
