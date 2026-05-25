import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

import 'guru_home_screen.dart';
import 'onboarding_screen.dart';

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
    await SyncHostResolver.resolve();
    if (!mounted) return;
    final user = widget.auth.currentUser;
    if (user != null && widget.auth.isOnboardingDone) {
      AppRouter.replace(
        context,
        GuruHomeScreen(user: user, auth: widget.auth),
      );
    } else {
      AppRouter.replace(context, OnboardingScreen(auth: widget.auth));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
