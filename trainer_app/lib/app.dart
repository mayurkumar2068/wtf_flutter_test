import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

import 'screens/bootstrap_screen.dart';

class TrainerApp extends ConsumerWidget {
  const TrainerApp({super.key, required this.auth});

  final AuthService auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppStrings.appNameTrainer,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(AppColors.trainer),
      home: BootstrapScreen(auth: auth),
    );
  }
}
