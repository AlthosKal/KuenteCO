import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/validate_verification_code_controller.dart';
import '../../core/services/app/auth_service.dart';
import '../../dto/auth/request/send_verification_code_dto.dart';
import '../../widgets/common/animated_background_scaffold_widget.dart';
import '../../widgets/common/blurred_card_widget.dart';
import '../../widgets/common/form_title_text.dart';
import '../../widgets/common/primary_button.dart';

class ValidateCodeScreen extends StatelessWidget {
  final String email;

  const ValidateCodeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return AnimatedBackgroundScaffold(child: ValidateCodeForm(email: email));
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
  final _validateController = ValidateVerificationCodeController();
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _validateController.startTimer(
          () => setState(() {}), // onTick para actualizar UI
          () => setState(() {}), // onFinished para actualizar UI
    );
  }

  @override
  void dispose() {
    for (var focus in _focusNodes) {
      focus.dispose();
    }
    _validateController.dispose();
    super.dispose();
  }

  void _submitValidateCode() {
    if (!_formKey.currentState!.validate()) return;

    final code = _validateController.getCodeInput();

    _validateController.validateVerificationCode(
      context: context,
      email: widget.email,
      code: code,
    );
  }

  void _onCodeFieldChange(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _resendCode() async {
    if (_validateController.timerCount > 0) return;

    final dto = SendVerificationCodeDTO(email: widget.email);
    await _authService.sendVerificationCode(isRegistration: true, dto: dto);

    _validateController.startTimer(
          () => setState(() {}),
          () => setState(() {}),
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
            FormTitleText(text: 'Ingresa el código de 6 dígitos enviado a:'),
            const SizedBox(height: 10),
            FormTitleText(text: widget.email),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                    (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: SizedBox(
                    width: 40,
                    child: TextFormField(
                      controller: _validateController.codeControllers[index],
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
                      onChanged: (value) => _onCodeFieldChange(value, index),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Código válido por: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  _validateController.formatTime(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed:
              _validateController.timerCount == 0 ? _resendCode : null,
              child: Text(
                'Reenviar código',
                style: TextStyle(
                  color:
                  _validateController.timerCount == 0
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ValueListenableBuilder(
              valueListenable: _validateController.isLoading,
              builder: (context, isLoading, _) {
                return isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : PrimaryButton(
                  label: 'Verificar Código',
                  onPressed: _submitValidateCode,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}