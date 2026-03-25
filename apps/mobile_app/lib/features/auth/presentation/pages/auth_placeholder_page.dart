import 'package:flutter/material.dart';

import '../widgets/auth_widgets.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'reset_password_page.dart';

class AuthPlaceholderPage extends StatelessWidget {
  const AuthPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScreenScaffold(
      eyebrow: 'Accesso protetto',
      title: 'Prendi in mano il profilo del tuo pet.',
      subtitle:
          'Login, registrazione e reset password in un unico spazio leggero, pensato per mobile e browser.',
      primaryActionLabel: 'Vai al login',
      secondaryActionLabel: 'Crea account',
      onPrimaryAction: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const LoginPage(),
          ),
        );
      },
      onSecondaryAction: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const RegisterPage(),
          ),
        );
      },
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthStateBanner(
            status: AuthBannerStatus.info,
            title: 'Pronto per il test',
            message:
                'Questa feature usa solo logica locale. Nessuna chiamata backend reale ancora.',
          ),
          const SizedBox(height: 16),
          AuthSurfaceCard(
            title: 'Percorsi rapidi',
            child: Column(
              children: [
                _AuthQuickTile(
                  title: 'Login',
                  subtitle: 'Entra con email e password',
                  icon: Icons.login_rounded,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _AuthQuickTile(
                  title: 'Registrazione',
                  subtitle: 'Crea il tuo account e accetta i termini',
                  icon: Icons.person_add_alt_1_rounded,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _AuthQuickTile(
                  title: 'Reset password',
                  subtitle: 'Recupera l accesso in pochi secondi',
                  icon: Icons.lock_reset_rounded,
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
        ],
      ),
    );
  }
}

class _AuthQuickTile extends StatelessWidget {
  const _AuthQuickTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF6F1E9),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF163A35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFFF8F4EE)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF173A35),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Color(0xFF5C726D),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
