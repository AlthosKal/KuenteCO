import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/validate_verification_code_controller.dart';
import '../../core/services/app/auth_service.dart';
import '../../dto/app/auth/request/send_verification_code_dto.dart';
import '../../widgets/common/background/animated_background_scaffold_widget.dart';
import '../../widgets/common/blurred_card_widget.dart';
import '../../widgets/common/buttoms/primary_buttom_widget.dart';
import '../../widgets/common/form/form_title_text_widget.dart';

class VerificationRegisterScreen extends StatelessWidget {
  final String email;

  const VerificationRegisterScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return AnimatedBackgroundScaffold(
      child: ValidateCodeForm(email: email),
    );
  }
}

class ValidateCodeForm extends StatefulWidget {
  final String email;

  const ValidateCodeForm({super.key, required this.email});

  @override
  State<ValidateCodeForm> createState() => _ValidateCodeFormState();
}

class _ValidateCodeFormState extends State<ValidateCodeForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ValidateVerificationCodeController();
  final _focusNodes = List.generate(6, (_) => FocusNode());
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _controller.startTimer(_refresh, _refresh);
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _submitCode() {
    if (_formKey.currentState?.validate() ?? false) {
      _controller.validateVerificationCode(
        context: context,
        email: widget.email,
        code: _controller.getCodeInput(),
      );
    }
  }

  void _onCodeChange(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _resendCode() async {
    if (_controller.timerCount > 0) return;

    await _authService.sendVerificationCode(
      isRegistration: true,
      dto: SendVerificationCodeDTO(email: widget.email),
    );

    _controller.startTimer(_refresh, _refresh);
  }

  Widget _buildCodeField(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: SizedBox(
        width: 40,
        child: TextFormField(
          controller: _controller.codeControllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white, fontSize: 22),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: '',
            border: UnderlineInputBorder(),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
          ),
          onChanged: (value) => _onCodeChange(value, index),
          validator: (value) => (value == null || value.isEmpty) ? '' : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return BlurredCard(
      width: isSmallScreen ? 360 : 400,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            FormTitleText(text: 'Ingresa el código de 6 dígitos enviado a:'),
            const SizedBox(height: 10),
            FormTitleText(text: widget.email),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, _buildCodeField),
            ),
            const SizedBox(height: 20),
            _buildTimerText(context),
            const SizedBox(height: 10),
            _buildResendButton(),
            const SizedBox(height: 30),
            _buildVerifyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerText(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Código válido por: ',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
        Text(
          _controller.formatTime(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildResendButton() {
    final isEnabled = _controller.timerCount == 0;
    return TextButton(
      onPressed: isEnabled ? _resendCode : null,
      child: Text(
        'Reenviar código',
        style: TextStyle(
          color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isLoading,
      builder: (_, isLoading, __) {
        return isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : PrimaryButton(label: 'Verificar Código', onPressed: _submitCode);
      },
    );
  }
}
