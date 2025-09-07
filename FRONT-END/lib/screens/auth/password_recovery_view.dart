import 'package:flutter/material.dart';

import '../../controllers/auth/change_password_controller.dart';
import '../../widgets/common/background/animated_background_scaffold_widget.dart';
import '../../widgets/common/blurred_card_widget.dart';
import '../../widgets/common/buttoms/primary_buttom_widget.dart';
import '../../widgets/common/form/form_title_text_widget.dart';
import '../../widgets/common/form/password_form_widget.dart';

class RecoverPasswordScreen extends StatelessWidget {
  final String email;
  final String code;

  const RecoverPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBackgroundScaffold(
      child: RecoverPasswordForm(email: email, code: code),
    );
  }
}

class RecoverPasswordForm extends StatefulWidget {
  final String email;
  final String code;

  const RecoverPasswordForm({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<RecoverPasswordForm> createState() => _RecoverPasswordFormState();
}

class _RecoverPasswordFormState extends State<RecoverPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _changePasswordController = ChangePasswordController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _changePasswordController.dispose();
    super.dispose();
  }

  /// ð Envía la solicitud para cambiar la contraseña
  void _submitChangePassword() {
    if (!_formKey.currentState!.validate()) return;

    _changePasswordController.changePassword(
      context: context,
      email: widget.email,
      code: widget.code,
      newPassword: _newPasswordController.text,
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
            FormTitleText(text: 'Ingresa tu nueva contraseña'),
            const SizedBox(height: 30),

            /// ð Campo nueva contraseña
            ValueListenableBuilder<bool>(
              valueListenable: _changePasswordController.obscurePassword,
              builder: (context, obscure, _) {
                return PasswordFormField(
                  controller: _newPasswordController,
                  focusNode: _newPasswordFocusNode,
                  onFieldSubmitted: (_) => _submitChangePassword(),
                );
              },
            ),

            /// ð Campo confirmar contraseña
            ValueListenableBuilder<bool>(
              valueListenable: _changePasswordController.obscurePassword,
              builder: (context, obscure, _) {
                return PasswordFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  labelText: 'Confirmar Contraseña',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            /// ð Botón para enviar nueva contraseña
            ValueListenableBuilder(
              valueListenable: _changePasswordController.isLoading,
              builder: (context, isLoading, _) {
                return isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : PrimaryButton(
                  onPressed: _submitChangePassword,
                  label: 'Cambiar Contraseña',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
