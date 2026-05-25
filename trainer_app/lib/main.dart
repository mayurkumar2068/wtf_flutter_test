import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthService();
  await auth.init();
  await SyncHostResolver.resolve();
  runApp(
    ProviderScope(
      child: TrainerApp(auth: auth),
    ),
  );
}
