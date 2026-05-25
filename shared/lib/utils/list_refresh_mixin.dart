import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Background refresh only while this route is visible (avoids off-screen work).
mixin ListRefreshMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Timer? _refreshTimer;
  final List<void Function()> _callbacks = [];
  Duration _interval = const Duration(seconds: 5);

  void registerAutoRefresh(
    void Function() onTick, {
    Duration interval = const Duration(seconds: 5),
  }) {
    _interval = interval;
    _callbacks.add(onTick);
    _restartTimer();
  }

  void _restartTimer() {
    _refreshTimer?.cancel();
    if (_callbacks.isEmpty) return;
    _refreshTimer = Timer.periodic(_interval, (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    for (final cb in _callbacks) {
      cb();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
