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
      title: 'Entra nel profilo del tuo pet in pochi secondi.',
      subtitle:
          'Login, registrazione e recupero accesso in un unico flusso pensato per la web app responsive e la futura release mobile.',
      primaryActionLabel: 'Vai al login',
      secondaryActionLabel: 'Crea un account',
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
            title: 'Demo pronta da mostrare',
            message:
                'L accesso qui e gia navigabile; alcune integrazioni restano in preview mentre prepariamo la release web-first.',
          ),
          const SizedBox(height: 16),
          AuthSurfaceCard(
            title: 'Percorso demo',
            child: Column(
              children: [
                _AuthQuickTile(
                  title: 'Accesso',
                  subtitle: 'Accedi e continua nel flusso principale.',
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
                  subtitle: 'Prepara il profilo owner per la prova.',
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
                  title: 'Recupero password',
                  subtitle: 'Simula il recupero accesso senza attrito.',
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
          const SizedBox(height: 16),
          const AuthStateBanner(
            status: AuthBannerStatus.success,
            title: 'Flusso web gia leggibile',
            message:
                'Lo scopo di questa schermata e far partire subito il percorso web: auth, home, pet, chat e reminder.',
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
      color: const Color(0xFFF6F2E8),
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
                        height: 1.3,
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

