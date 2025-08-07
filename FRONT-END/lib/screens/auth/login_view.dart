import 'package:KuenteCO/widgets/common/navbar/custom_form_widget.dart';
import 'package:flutter/material.dart';
import '../../controllers/login_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/background/animated_background_scaffold_widget.dart';
import '../../widgets/common/blurred_card_widget.dart';
import '../../widgets/common/form/email_form_widget.dart';
import '../../widgets/common/form/form_title_text_widget.dart';
import '../../widgets/common/form/password_form_widget.dart';
import '../../widgets/common/primary_buttom_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedBackgroundScaffold(child: LoginForm());
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = LoginController();
  final _nameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameOrEmailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameOrEmailController.dispose();
    _passwordController.dispose();
    _nameOrEmailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _loginController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (!_formKey.currentState!.validate()) return;

    _loginController.login(
      context: context,
      nameOrEmail: _nameOrEmailController.text,
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
            FormTitleText(text: 'Inicio de Sesión'),
            const SizedBox(height: 20),

            /// ✅ Campo email/usuario
            CustomFormField(
              controller: _nameOrEmailController,
              focusNode: _nameOrEmailFocusNode,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              }, labelText: 'Email o Usuario',
            ),
            const SizedBox(height: 12),

            /// ✅ Campo contraseña
            ValueListenableBuilder<bool>(
              valueListenable: _loginController.obscurePassword,
              builder: (context, obscure, _) {
                return PasswordFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  onFieldSubmitted: (_) => _submitLogin(),
                );
              },
            ),
            const SizedBox(height: 10),

            /// ✅ Checkbox de recordar contraseña
            ValueListenableBuilder<bool>(
              valueListenable: _loginController.rememberPassword,
              builder: (context, remember, _) {
                return Row(
                  children: [
                    Checkbox(
                      value: remember,
                      onChanged: _loginController.toggleRememberPassword,
                      checkColor: Colors.black,
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                            (states) => states.contains(WidgetState.selected)
                            ? Colors.white
                            : Colors.transparent,
                      ),
                    ),
                    const Text(
                      'Recordar contraseña',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            /// ✅ Botón de login
            ValueListenableBuilder<bool>(
              valueListenable: _loginController.isLoading,
              builder: (context, isLoading, _) {
                return isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : PrimaryButton(label: 'Ingresar', onPressed: _submitLogin);
              },
            ),
            const SizedBox(height: 12),

            /// ✅ Botón de registro
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
              child: const Text.rich(
                TextSpan(
                  text: '¿No tienes una cuenta? ',
                  style: TextStyle(color: Colors.white),
                  children: [
                    TextSpan(
                      text: 'Regístrate',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            /// ✅ Botón de recuperar contraseña
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.sendVerificationCode),
              child: const Text.rich(
                TextSpan(
                  text: '¿Olvidaste tu contraseña? ',
                  style: TextStyle(color: Colors.white),
                  children: [
                    TextSpan(
                      text: 'Recupérala',
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
