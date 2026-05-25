import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class PrejoinCallScreen extends ConsumerStatefulWidget {
  const PrejoinCallScreen({
    super.key,
    required this.me,
    required this.peer,
    required this.room,
    required this.callRequest,
    required this.isTrainer,
  });

  final User me;
  final User peer;
  final RoomMeta room;
  final CallRequest callRequest;
  final bool isTrainer;

  @override
  ConsumerState<PrejoinCallScreen> createState() => _PrejoinCallScreenState();
}

class _PrejoinCallScreenState extends ConsumerState<PrejoinCallScreen> {
  bool _micOn = true;
  bool _camOn = true;
  bool _joining = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.deviceCheck)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.readyToJoin,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _camOn
                    ? const Center(
                        child: Icon(Icons.videocam, size: 64, color: Colors.white54),
                      )
                    : const Center(
                        child: Icon(Icons.videocam_off, size: 64, color: Colors.white54),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Role: ${widget.isTrainer ? widget.room.hmsRoleTrainer : widget.room.hmsRoleMember}',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MicToggle(
                  on: _micOn,
                  onTap: () => setState(() => _micOn = !_micOn),
                ),
                const SizedBox(width: 24),
                _CamToggle(
                  on: _camOn,
                  onTap: () => setState(() => _camOn = !_camOn),
                ),
              ],
            ),
            const Spacer(),
            FilledButton(
              onPressed: _joining ? null : _join,
              child: _joining
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(AppStrings.joinCallBtn),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _join() async {
    setState(() => _joining = true);
    final call = ref.read(callServiceProvider);
    final ok = await call.requestPermissions();
    if (!ok && mounted) {
      showErrorSnack(context, AppStrings.permissionsRequired);
      setState(() => _joining = false);
      return;
    }
    try {
      await call.joinRoom(
        user: widget.me,
        room: widget.room,
        isTrainer: widget.isTrainer,
      );
      if (!mounted) return;
      AppRouter.openIncall(
        context,
        me: widget.me,
        peer: widget.peer,
        isTrainer: widget.isTrainer,
        memberId: widget.isTrainer ? widget.peer.id : widget.me.id,
        trainerId: widget.isTrainer ? widget.me.id : widget.peer.id,
      );
    } catch (e) {
      if (mounted) {
        showErrorSnack(context, AppStrings.couldNotJoin, detail: e.toString());
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }
}

class _MicToggle extends StatelessWidget {
  const _MicToggle({required this.on, required this.onTap});

  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      iconSize: 32,
      icon: Icon(on ? Icons.mic_rounded : Icons.mic_off_rounded),
      style: IconButton.styleFrom(
        backgroundColor:
            on ? Theme.of(context).colorScheme.primary : AppColors.neutral200,
        foregroundColor: on ? Colors.white : AppColors.neutral700,
      ),
      onPressed: onTap,
    );
  }
}

class _CamToggle extends StatelessWidget {
  const _CamToggle({required this.on, required this.onTap});

  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      iconSize: 32,
      icon: Icon(on ? Icons.videocam_rounded : Icons.videocam_off_rounded),
      style: IconButton.styleFrom(
        backgroundColor:
            on ? Theme.of(context).colorScheme.primary : AppColors.neutral200,
        foregroundColor: on ? Colors.white : AppColors.neutral700,
      ),
      onPressed: onTap,
    );
  }
}
