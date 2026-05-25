import 'package:flutter/material.dart';

import '../../models/call_request.dart';
import '../../models/room_meta.dart';
import '../../models/user.dart';
import '../../screens/conversation_screen.dart';
import '../../screens/incall_screen.dart';
import '../../screens/prejoin_call_screen.dart';
import '../../screens/sessions_screen.dart';
/// Central navigation — no scattered MaterialPageRoute in features.
class AppRouter {
  AppRouter._();

  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static void replace(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }

  // --- Shared screens ---

  static Future<void> openConversation(
    BuildContext context, {
    required User me,
    required User peer,
    CallRequest? upcomingCall,
  }) =>
      push(
        context,
        ConversationScreen(me: me, peer: peer, upcomingCall: upcomingCall),
      );

  static Future<void> openSessions(
    BuildContext context, {
    required User user,
    required bool isTrainer,
  }) =>
      push(
        context,
        SessionsScreen(user: user, isTrainer: isTrainer),
      );

  static Future<void> openPrejoin(
    BuildContext context, {
    required User me,
    required User peer,
    required RoomMeta room,
    required CallRequest callRequest,
    required bool isTrainer,
  }) =>
      push(
        context,
        PrejoinCallScreen(
          me: me,
          peer: peer,
          room: room,
          callRequest: callRequest,
          isTrainer: isTrainer,
        ),
      );

  static void openIncall(
    BuildContext context, {
    required User me,
    required User peer,
    required bool isTrainer,
    required String memberId,
    required String trainerId,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => IncallScreen(
          me: me,
          peer: peer,
          isTrainer: isTrainer,
          memberId: memberId,
          trainerId: trainerId,
        ),
      ),
    );
  }
}
