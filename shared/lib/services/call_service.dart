import 'dart:async';
import 'dart:io';

import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../models/room_meta.dart';
import '../models/session_log.dart';
import '../models/user.dart';
import '../utils/app_logger.dart';
import '../utils/time_utils.dart';
import 'sync_client.dart';

class CallService implements HMSUpdateListener {
  CallService(this._sync);

  final SyncClient _sync;
  final _uuid = const Uuid();
  HMSSDK? _hmsSdk;
  DateTime? _callStartedAt;
  String? _activeSessionId;
  String? _activeCallRequestId;

  final _peersController = StreamController<List<HMSPeer>>.broadcast();
  final _connectionController = StreamController<HMSRoomUpdate>.broadcast();
  final _reconnectingController = StreamController<bool>.broadcast();

  Stream<List<HMSPeer>> get peers => _peersController.stream;
  Stream<HMSRoomUpdate> get roomUpdates => _connectionController.stream;
  Stream<bool> get reconnecting => _reconnectingController.stream;

  HMSPeer? localPeer;
  List<HMSPeer> remotePeers = [];
  bool isMuted = false;
  bool isVideoOn = true;

  Future<void> initSdk() async {
    if (_hmsSdk != null) return;
    _hmsSdk = HMSSDK();
    await _hmsSdk!.build();
    _hmsSdk!.addUpdateListener(listener: this);
    AppLogger.instance.log(LogTag.rtc, 'HMS SDK initialized');
  }

  Future<bool> requestPermissions() async {
    if (Platform.isIOS) return true;
    await Permission.camera.request();
    await Permission.microphone.request();
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    return (await Permission.camera.isGranted) &&
        (await Permission.microphone.isGranted);
  }

  Future<void> joinRoom({
    required User user,
    required RoomMeta room,
    required bool isTrainer,
  }) async {
    await initSdk();
    final role = isTrainer ? room.hmsRoleTrainer : room.hmsRoleMember;
    final token = await _sync.fetchHmsToken(
      userId: user.id,
      role: role,
      roomId: room.hmsRoomId,
    );
    _activeCallRequestId = room.callRequestId;
    _callStartedAt = DateTime.now();
    final config = HMSConfig(authToken: token, userName: user.name);
    await _hmsSdk!.join(config: config);
    AppLogger.instance.log(LogTag.rtc, 'Joining room ${room.hmsRoomId}');
  }

  Future<void> leaveCall({
    required String memberId,
    required String trainerId,
  }) async {
    await _hmsSdk?.leave();
    if (_callStartedAt != null) {
      final ended = DateTime.now();
      final log = SessionLog(
        id: _uuid.v4(),
        memberId: memberId,
        trainerId: trainerId,
        startedAt: _callStartedAt!,
        endedAt: ended,
        durationSec: calculateDurationSec(_callStartedAt!, ended),
        callRequestId: _activeCallRequestId,
      );
      final created = await _sync.createSession(log);
      _activeSessionId = created.id;
      AppLogger.instance.log(LogTag.rtc, 'Session log created ${created.id}');
    }
    _callStartedAt = null;
  }

  String? get activeSessionId => _activeSessionId;

  Future<void> toggleMute() async {
    if (localPeer?.audioTrack == null) return;
    isMuted = !isMuted;
    await _hmsSdk?.toggleMicMuteState();
  }

  Future<void> toggleVideo() async {
    if (localPeer?.videoTrack == null) return;
    isVideoOn = !isVideoOn;
    await _hmsSdk?.toggleCameraMuteState();
  }

  Future<void> flipCamera() async {
    await _hmsSdk?.switchCamera();
  }

  Future<RoomMeta?> roomForCall(String callRequestId) =>
      _sync.getRoomForCall(callRequestId);

  @override
  void onJoin({required HMSRoom room}) {
    AppLogger.instance.log(LogTag.rtc, 'Joined room ${room.id}');
    _reconnectingController.add(false);
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (peer.isLocal) {
      localPeer = peer;
    } else {
      final idx = remotePeers.indexWhere((p) => p.peerId == peer.peerId);
      if (idx >= 0) {
        remotePeers[idx] = peer;
      } else {
        remotePeers.add(peer);
      }
    }
    _peersController.add([...remotePeers, if (localPeer != null) localPeer!]);
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    _connectionController.add(update);
  }

  @override
  void onHMSError({required HMSException error}) {
    AppLogger.instance.log(LogTag.rtc, 'HMS error: ${error.message}');
    if (error.code?.errorCode == 5001) {
      // Token expired — refresh would go here in production
      AppLogger.instance.log(LogTag.rtc, 'Token may be expired');
    }
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {}

  @override
  void onPeerListUpdate({
    required List<HMSPeer> addedPeers,
    required List<HMSPeer> removedPeers,
  }) {
    for (final p in removedPeers) {
      remotePeers.removeWhere((e) => e.peerId == p.peerId);
    }
    for (final p in addedPeers) {
      if (!p.isLocal) remotePeers.add(p);
    }
    _peersController.add(remotePeers);
  }

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onChangeTrackStateRequest({
    required HMSTrackChangeRequest hmsTrackChangeRequest,
  }) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onReconnected() {
    _reconnectingController.add(false);
  }

  @override
  void onReconnecting() {
    _reconnectingController.add(true);
  }

  @override
  void onRemovedFromRoom({
    required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer,
  }) {}

  @override
  void onAudioDeviceChanged({
    HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice,
  }) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  void dispose() {
    _peersController.close();
    _connectionController.close();
    _reconnectingController.close();
  }
}
