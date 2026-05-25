import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/call_request.dart';
import '../models/message.dart';
import '../models/room_meta.dart';
import '../models/session_log.dart';
import '../models/user.dart';
import '../utils/app_logger.dart';
import '../utils/sync_host_resolver.dart';

typedef WsEventHandler = void Function(String type, Map<String, dynamic> data);

class SyncClient {
  SyncClient();

  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get events => _eventController.stream;
  String get baseUrl => SyncHostResolver.baseUrl;
  String get _api => SyncHostResolver.baseUrl;

  Future<List<User>> fetchUsers() async {
    final res = await http.get(Uri.parse('$_api/api/users'));
    _check(res);
    final list = jsonDecode(res.body) as List;
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<User?> getUser(String id) async {
    final res = await http.get(Uri.parse('$_api/api/users/$id'));
    if (res.statusCode == 404) return null;
    _check(res);
    return User.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<Message>> fetchMessages(String chatId) async {
    final res = await http.get(
      Uri.parse('$_api/api/messages?chatId=$chatId'),
    );
    _check(res);
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Uploads image to server; returns full URL both apps can load.
  Future<String> uploadChatImage(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final lower = filePath.toLowerCase();
    final mime = lower.endsWith('.png') ? 'image/png' : 'image/jpeg';
    final res = await http.post(
      Uri.parse('$_api/api/upload/chat-image'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'base64': base64Encode(bytes), 'mime': mime}),
    );
    _check(res);
    final path = (jsonDecode(res.body) as Map<String, dynamic>)['url'] as String;
    return '$_api$path';
  }

  Future<Message> sendMessage(Message message) async {
    final res = await http.post(
      Uri.parse('$_api/api/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(message.toJson()),
    );
    _check(res);
    AppLogger.instance.log(LogTag.chat, 'Sent message ${message.id}');
    return Message.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> markMessagesRead(String chatId, String readerId) async {
    await http.post(
      Uri.parse('$_api/api/messages/read'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'chatId': chatId, 'readerId': readerId}),
    );
  }

  Future<List<CallRequest>> fetchCallRequests({String? userId}) async {
    var url = '$_api/api/call-requests';
    if (userId != null) url += '?userId=$userId';
    final res = await http.get(Uri.parse(url));
    _check(res);
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => CallRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CallRequest> createCallRequest(CallRequest request) async {
    final res = await http.post(
      Uri.parse('$_api/api/call-requests'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    _check(res);
    AppLogger.instance.log(LogTag.schedule, 'Created call request');
    return CallRequest.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<CallRequest> updateCallRequest(
    String id, {
    required String status,
    String? declineReason,
  }) async {
    final res = await http.patch(
      Uri.parse('$_api/api/call-requests/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': status,
        if (declineReason != null) 'declineReason': declineReason,
      }),
    );
    _check(res);
    return CallRequest.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<RoomMeta?> getRoomForCall(String callRequestId) async {
    final res = await http.get(
      Uri.parse('$_api/api/rooms?callRequestId=$callRequestId'),
    );
    if (res.statusCode == 404) return null;
    _check(res);
    return RoomMeta.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<SessionLog>> fetchSessions({String? userId}) async {
    var url = '$_api/api/sessions';
    if (userId != null) url += '?userId=$userId';
    final res = await http.get(Uri.parse(url));
    _check(res);
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => SessionLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SessionLog> createSession(SessionLog log) async {
    final res = await http.post(
      Uri.parse('$_api/api/sessions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(log.toJson()),
    );
    _check(res);
    return SessionLog.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<SessionLog> patchSession(
    String id, {
    int? rating,
    String? memberNotes,
    String? trainerNotes,
  }) async {
    final res = await http.patch(
      Uri.parse('$_api/api/sessions/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (rating != null) 'rating': rating,
        if (memberNotes != null) 'memberNotes': memberNotes,
        if (trainerNotes != null) 'trainerNotes': trainerNotes,
      }),
    );
    _check(res);
    return SessionLog.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<String> fetchHmsToken({
    required String userId,
    required String role,
    String? roomId,
  }) async {
    var url =
        '$_api/token?userId=$userId&role=$role';
    if (roomId != null) url += '&roomId=$roomId';
    final res = await http.get(Uri.parse(url));
    _check(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    AppLogger.instance.log(LogTag.rtc, 'Fetched HMS token for $userId');
    return body['token'] as String;
  }

  Future<bool> healthCheck() async => SyncHostResolver.resolve();

  void emitLocalEvent(String type, Map<String, dynamic> data) {
    _eventController.add({'type': type, ...data});
  }

  void _check(http.Response res) {
    if (res.statusCode >= 400) {
      throw Exception('API error ${res.statusCode}: ${res.body}');
    }
  }

  void dispose() => _eventController.close();
}
