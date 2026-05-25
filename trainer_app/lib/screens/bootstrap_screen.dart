import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

import 'login_screen.dart';
import 'trainer_home_screen.dart';

class BootstrapScreen extends ConsumerStatefulWidget {
  const BootstrapScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  ConsumerState<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends ConsumerState<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final user = widget.auth.currentUser;
    if (user != null && widget.auth.isOnboardingDone) {
      AppRouter.replace(
        context,
        TrainerHomeScreen(user: user, auth: widget.auth),
      );
    } else {
      AppRouter.replace(context, LoginScreen(auth: widget.auth));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
