import 'package:flutter/material.dart';

import '../../controllers/register_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/animated_background_scaffold_widget.dart';
import '../../widgets/common/blurred_card_widget.dart';
import '../../widgets/common/custom_form_widget.dart';
import '../../widgets/common/email_form_widget.dart';
import '../../widgets/common/form_title_text.dart';
import '../../widgets/common/password_form_widget.dart';
import '../../widgets/common/primary_button.dart';


class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBackgroundScaffold(child: const RegisterForm());
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
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

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
    super.dispose();
  }

  void _submitRegister() {
    if (!_formKey.currentState!.validate()) return;

    _registerController.register(
      context: context,
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
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
            CustomFormField(
              controller: _usernameController,
              focusNode: _usernameFocusNode,
              labelText: 'Nombre Completo',
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Campo requerido';
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_emailFocusNode);
              },
            ),
            const SizedBox(height: 12),
            EmailFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: _registerController.obscurePassword,
              builder: (context, obscure, _) {
                return PasswordFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(
                      context,
                    ).requestFocus(_confirmPasswordFocusNode);
                  },
                );
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _registerController.obscurePassword,
              builder: (context, obscure, _) {
                return PasswordFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  labelText: 'Confirmar Contraseña',
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Campo requerido';
                    if (value != _passwordController.text)
                      return 'Las contraseñas no coinciden';
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 20),
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
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              child: const Text.rich(
                TextSpan(
                  text: '¿Ya tienes una cuenta? ',
                  style: TextStyle(color: Colors.white),
                  children: [
                    TextSpan(
                      text: 'Inicía Sesión',
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
}