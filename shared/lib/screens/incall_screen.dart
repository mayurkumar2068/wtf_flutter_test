import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:wtf_shared/wtf_shared.dart';

import 'post_call_sheets.dart';

class IncallScreen extends ConsumerStatefulWidget {
  const IncallScreen({
    super.key,
    required this.me,
    required this.peer,
    required this.isTrainer,
    required this.memberId,
    required this.trainerId,
  });

  final User me;
  final User peer;
  final bool isTrainer;
  final String memberId;
  final String trainerId;

  @override
  ConsumerState<IncallScreen> createState() => _IncallScreenState();
}

class _IncallScreenState extends ConsumerState<IncallScreen> {
  List<HMSPeer> _peers = [];
  bool _reconnecting = false;

  @override
  void initState() {
    super.initState();
    final call = ref.read(callServiceProvider);
    call.peers.listen((p) {
      if (mounted) setState(() => _peers = p);
    });
    call.reconnecting.listen((r) {
      if (mounted) setState(() => _reconnecting = r);
    });
  }

  Future<void> _endCall() async {
    final call = ref.read(callServiceProvider);
    await call.leaveCall(
      memberId: widget.memberId,
      trainerId: widget.trainerId,
    );
    if (!mounted) return;
    final sessionId = call.activeSessionId;
    Navigator.pop(context);
    if (sessionId != null) {
      showPostCallFlow(context, ref, sessionId, widget.isTrainer);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session saved to your logs.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final call = ref.watch(callServiceProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Call with ${widget.peer.name}',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _peers.isEmpty ? 2 : _peers.length,
                    itemBuilder: (context, i) {
                      final peer = _peers.length > i ? _peers[i] : null;
                      final name = peer?.name ?? (i == 0 ? widget.me.name : widget.peer.name);
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.neutral700,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const Center(
                              child: Icon(Icons.person, size: 48, color: Colors.white54),
                            ),
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Text(
                                name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _btn(Icons.mic_off, call.isMuted, call.toggleMute),
                      _btn(Icons.videocam_off, !call.isVideoOn, call.toggleVideo),
                      _btn(Icons.cameraswitch, false, call.flipCamera),
                      if (widget.isTrainer)
                        FloatingActionButton(
                          backgroundColor: AppColors.error,
                          onPressed: _endCall,
                          child: const Icon(Icons.call_end),
                        )
                      else
                        FloatingActionButton(
                          backgroundColor: AppColors.error,
                          onPressed: _endCall,
                          child: const Icon(Icons.call_end),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_reconnecting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text('Reconnecting...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, bool active, Future<void> Function() onTap) {
    return IconButton.filled(
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: active ? AppColors.error : Colors.white24,
      ),
      onPressed: () => onTap(),
    );
  }
}
