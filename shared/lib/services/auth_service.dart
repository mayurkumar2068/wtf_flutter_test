import 'package:hive_flutter/hive_flutter.dart';

import '../models/user.dart';
import '../utils/app_logger.dart';

class AuthService {
  static const _boxName = 'auth_box';
  static const _userKey = 'current_user';
  static const _onboardingKey = 'onboarding_done';

  Box? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// Hive init for unit tests (no Flutter binding).
  Future<void> initForTest(String directory) async {
    Hive.init(directory);
    _box = await Hive.openBox(_boxName);
  }

  bool get isOnboardingDone => _box?.get(_onboardingKey, defaultValue: false) as bool;

  User? get currentUser {
    final raw = _box?.get(_userKey);
    if (raw == null) return null;
    return User.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> completeOnboarding(User user) async {
    await _box?.put(_userKey, user.toJson());
    await _box?.put(_onboardingKey, true);
    AppLogger.instance.log(LogTag.auth, 'Onboarding complete: ${user.name}');
  }

  Future<void> login(User user) async {
    await _box?.put(_userKey, user.toJson());
    await _box?.put(_onboardingKey, true);
    AppLogger.instance.log(LogTag.auth, 'Login: ${user.name}');
  }

  Future<void> clearSession() async {
    await _box?.delete(_userKey);
    await _box?.delete(_onboardingKey);
    AppLogger.instance.log(LogTag.auth, 'Session cleared');
  }

  String chatIdFor(User a, User b) {
    final ids = [a.id, b.id]..sort();
    return 'chat_${ids[0]}_${ids[1]}';
  }
}
