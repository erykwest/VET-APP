import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../widgets/auth_widgets.dart';
import 'register_page.dart';
import 'reset_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthBannerStatus _status = AuthBannerStatus.info;
  String _title = 'Compila i campi per entrare.';
  String _message = 'Usiamo solo stato locale, senza backend reale.';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _status = AuthBannerStatus.error;
        _title = 'Controlla i dati';
        _message = 'Serve un indirizzo email valido e una password di almeno 6 caratteri.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = AuthBannerStatus.loading;
      _title = 'Verifica in corso';
      _message = 'Simuliamo il caricamento del login per testare gli stati UI.';
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    final shouldFail = _emailController.text.contains('fail');
    setState(() {
      _isLoading = false;
      if (shouldFail) {
        _status = AuthBannerStatus.error;
        _title = 'Login non riuscito';
        _message = 'Abbiamo simulato un errore. Prova un altra email o correggi i dati.';
      } else {
        _status = AuthBannerStatus.success;
        _title = 'Login pronto';
        _message = 'Stato successivo simulato. Ti porto nella home shell di anteprima.';
      }
    });

    if (!shouldFail) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.homeShell,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenScaffold(
      eyebrow: 'Login',
      title: 'Bentornato.',
      subtitle: 'Accedi per ritrovare il pet attivo, i promemoria e i documenti salvati.',
      primaryActionLabel: 'Entra',
      secondaryActionLabel: 'Vai alla registrazione',
      onPrimaryAction: _submit,
      onSecondaryAction: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const RegisterPage(),
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
            title: 'Accesso rapido',
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
                  const SizedBox(height: 14),
                  AuthInputField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Almeno 6 caratteri',
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    validator: (value) {
                      final text = value ?? '';
                      if (text.isEmpty) return 'Inserisci la password.';
                      if (text.length < 6) return 'Minimo 6 caratteri.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
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
                          : const Text('Accedi'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AuthFooterLink(
                    label: 'Hai dimenticato la password?',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ResetPasswordPage(),
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
