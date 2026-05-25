import 'package:flutter/material.dart';
import 'package:wtf_shared/wtf_shared.dart';

import 'trainer_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  static const _aarav = User(
    id: 'trainer_aarav',
    role: UserRole.trainer,
    name: 'Aarav (Lead Trainer)',
    email: 'aarav@wtf.fitness',
    avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Aarav',
  );

  Future<void> _login() async {
    setState(() => _loading = true);
    await widget.auth.login(_aarav);
    if (!mounted) return;
    AppRouter.replace(
      context,
      TrainerHomeScreen(user: _aarav, auth: widget.auth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.sports_gymnastics, size: 64, color: primary),
              const SizedBox(height: 20),
              Text(
                AppStrings.trainerLoginTitle,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.trainerLoginSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  WtfAvatar(url: _aarav.avatarUrl, radius: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _aarav.name,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          _aarav.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(AppStrings.continueAsAarav),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
