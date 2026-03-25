import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/auth_widgets.dart';
import 'login_page.dart';
import 'register_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  AuthBannerStatus _status = AuthBannerStatus.info;
  String _title = 'Recupera il tuo accesso.';
  String _message = 'Simuliamo l invio della mail di reset.';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _status = AuthBannerStatus.error;
        _title = 'Email non valida';
        _message = 'Inserisci un indirizzo email corretto per continuare.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = AuthBannerStatus.loading;
      _title = 'Invio in corso';
      _message = 'Simuliamo la richiesta di reset password.';
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    final shouldFail = _emailController.text.contains('fail');
    setState(() {
      _isLoading = false;
      if (shouldFail) {
        _status = AuthBannerStatus.error;
        _title = 'Invio fallito';
        _message = 'Abbiamo simulato un errore. Prova con un altro indirizzo email.';
      } else {
        _status = AuthBannerStatus.success;
        _title = 'Mail pronta';
        _message = 'Il reset e stato simulato correttamente. Backend reale dopo.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenScaffold(
      eyebrow: 'Reset password',
      title: 'Nessun problema, ricominciamo.',
      subtitle:
          'Inserisci la tua email e simula l invio del link di recupero accesso.',
      primaryActionLabel: 'Invia link',
      secondaryActionLabel: 'Torna al login',
      onPrimaryAction: _submit,
      onSecondaryAction: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const LoginPage(),
          ),
        );
      },
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthStateBanner(
            status: _status,
            title: _title,
            message: _message,
          ),
          const SizedBox(height: 16),
          AuthSurfaceCard(
            title: 'Recupero accesso',
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AuthInputField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'nome@dominio.it',
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Inserisci la tua email.';
                      if (!text.contains('@')) return 'Email non valida.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Invia link'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AuthFooterLink(
                    label: 'Torna alla registrazione',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RegisterPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
