import 'package:KuenteCO/controllers/auth/profile_login_controller.dart';
import 'package:KuenteCO/utils/enum/login_type_enum.dart';
import 'package:KuenteCO/widgets/common/form/custom_form_widget.dart';
import 'package:flutter/material.dart';

import '../../controllers/auth/login_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/background/animated_background_scaffold_widget.dart';
import '../../widgets/common/blurred_card_widget.dart';
import '../../widgets/common/buttoms/primary_buttom_widget.dart';
import '../../widgets/common/form/form_title_text_widget.dart';
import '../../widgets/common/form/password_form_widget.dart';

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
  final _profileLoginController = ProfileLoginController();
  final _nameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameOrEmailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  /// â Estado del tipo de login usando enum
  final ValueNotifier<LoginType> _selectedLoginType =
      ValueNotifier<LoginType>(LoginType.USER);

  @override
  void dispose() {
    _nameOrEmailController.dispose();
    _passwordController.dispose();
    _nameOrEmailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _loginController.dispose();
    _profileLoginController.dispose();
    _selectedLoginType.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (!_formKey.currentState!.validate()) return;

    // Decidir quÃ© tipo de login usar basado en la selecciÃ³n
    if (_selectedLoginType.value == LoginType.USER) {
      _loginController.login(
        context: context,
        nameOrEmail: _nameOrEmailController.text,
        password: _passwordController.text,
      );
    } else {
      _profileLoginController.profileLogin(
        context: context,
        nameOrEmail: _nameOrEmailController.text,
        password: _passwordController.text,
      );
    }
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

            /// â Campo email/usuario
            CustomFormField(
              controller: _nameOrEmailController,
              focusNode: _nameOrEmailFocusNode,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              }, labelText: 'Email o Usuario',
            ),
            const SizedBox(height: 12),

            /// â Campo contraseÃ±a
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

            /// ð¥ Selector de tipo de login
            const Text(
              'Iniciar sesión como',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            ValueListenableBuilder<LoginType>(
              valueListenable: _selectedLoginType,
              builder: (context, selected, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLoginTypeButton(
                      label: 'Usuario',
                      icon: Icons.person,
                      isSelected: selected == LoginType.USER,
                      onTap: () => _selectedLoginType.value = LoginType.USER,
                    ),
                    const SizedBox(width: 10),
                    _buildLoginTypeButton(
                      label: 'Perfil',
                      icon: Icons.account_circle,
                      isSelected: selected == LoginType.PROFILE,
                      onTap: () => _selectedLoginType.value = LoginType.PROFILE,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),

            /// â Checkbox de recordar contraseÃ±a
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

            /// â BotÃ³n de login
            ValueListenableBuilder<LoginType>(
              valueListenable: _selectedLoginType,
              builder: (context, loginType, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: loginType == LoginType.USER
                      ? _loginController.isLoading
                      : _profileLoginController.isLoading,
                  builder: (context, isLoading, _) {
                    return isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : PrimaryButton(
                            label: loginType == LoginType.USER ? 'Ingresar' : 'Ingresar como Perfil',
                            onPressed: _submitLogin,
                          );
                  },
                );
              },
            ),
            const SizedBox(height: 12),

            /// â BotÃ³n de registro
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
              child: const Text.rich(
                TextSpan(
                  text: '¿No tienes una cuenta? ',
                  style: TextStyle(color: Colors.white),
                  children: [
                    TextSpan(
                      text: 'Registrate',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            /// â BotÃ³n de recuperar contraseÃ±a
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.sendVerificationCode),
              child: const Text.rich(
                TextSpan(
                  text: '¿Olvidaste tu contraseÃ±a? ',
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

  /// ð¨ BotÃ³n custom para Usuario / Perfil
  Widget _buildLoginTypeButton({
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
