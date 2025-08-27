import 'package:flutter/material.dart';
import '../../controllers/send_verification_code_controller.dart';
import '../../widgets/common/background/animated_background_scaffold_widget.dart';
import '../../widgets/common/blurred_card_widget.dart';
import '../../widgets/common/buttoms/primary_buttom_widget.dart';
import '../../widgets/common/form/email_form_widget.dart';
import '../../widgets/common/form/form_title_text_widget.dart';

class VerificationCodeScreen extends StatelessWidget {
  const VerificationCodeScreen ({super.key, required String email});

  @override
  Widget build(BuildContext context) {
    return AnimatedBackgroundScaffold(child: const VerificationCodeForm());
  }
}

class VerificationCodeForm extends StatefulWidget {
  const VerificationCodeForm({super.key});

  @override
  State<VerificationCodeForm> createState() => _VerificationCodeFormState();
}

class _VerificationCodeFormState extends State<VerificationCodeForm> {
  final _formKey = GlobalKey<FormState>();
  final _sendVerificationCodeController = SendVerificationCodeController();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _sendVerificationCodeController.dispose();
    super.dispose();
  }

  void _submitSendVerificationCode() {
    if (!_formKey.currentState!.validate()) return;

    _sendVerificationCodeController.sendVerificationCode(
      context: context,
      email: _emailController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return BlurredCard(
      width: isSmallScreen ? 360.0 : 400.0,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            FormTitleText(
              text:
              'Ingresa tu correo electrónico para recibir un código de verificación',
            ),
            const SizedBox(height: 12),
            EmailFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder(
              valueListenable: _sendVerificationCodeController.isLoading,
              builder: (context, isLoading, _) {
                return isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : PrimaryButton(
                  label: 'Enviar Código',
                  onPressed: _submitSendVerificationCode,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}