import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

import 'screens/bootstrap_screen.dart';

class GuruApp extends ConsumerWidget {
  const GuruApp({super.key, required this.auth});

  final AuthService auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'WTF Guru',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(AppColors.guru),
      home: BootstrapScreen(auth: auth),
    );
  }
}
