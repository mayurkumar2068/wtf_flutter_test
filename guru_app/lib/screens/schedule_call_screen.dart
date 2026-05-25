import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wtf_shared/wtf_shared.dart';

class ScheduleCallScreen extends ConsumerStatefulWidget {
  const ScheduleCallScreen({super.key, required this.user});

  final User user;

  @override
  ConsumerState<ScheduleCallScreen> createState() => _ScheduleCallScreenState();
}

class _ScheduleCallScreenState extends ConsumerState<ScheduleCallScreen>
    with ListRefreshMixin {
  DateTime _selectedDay = DateTime.now();
  String? _selectedSlot;
  final _noteController = TextEditingController();
  bool _submitting = false;

  static const _slots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
    '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
  ];

  @override
  void initState() {
    super.initState();
    registerAutoRefresh(() => refreshCallRequests(ref, widget.user.id));
  }

  List<DateTime> get _days {
    final now = DateTime.now();
    return List.generate(3, (i) => DateTime(now.year, now.month, now.day + i));
  }

  DateTime? _scheduledDateTime() {
    if (_selectedSlot == null) return null;
    final parts = _selectedSlot!.split(':');
    return DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  Future<void> _submit(List<CallRequest> existing) async {
    final scheduled = _scheduledDateTime();
    if (scheduled == null) {
      showErrorSnack(context, AppStrings.selectTimeSlot);
      return;
    }

    final validation = SchedulerValidator.validateNewRequest(
      scheduledFor: scheduled,
      existing: existing,
      memberId: widget.user.id,
      trainerId: widget.user.assignedTrainerId,
    );
    if (!validation.valid) {
      showErrorSnack(context, validation.error!);
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(syncClientProvider).createCallRequest(
            CallRequest(
              id: 'req_${DateTime.now().millisecondsSinceEpoch}',
              memberId: widget.user.id,
              trainerId: widget.user.assignedTrainerId ?? 'trainer_aarav',
              requestedAt: DateTime.now(),
              scheduledFor: scheduled,
              note: _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.requestSent),
          behavior: SnackBarBehavior.floating,
        ),
      );
      refreshCallRequests(ref, widget.user.id);
    } catch (e) {
      if (mounted) {
        showErrorSnack(context, AppStrings.couldNotSubmit, detail: e.toString());
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _openJoin(CallRequest r) async {
    final users = await ref.read(usersProvider.future);
    final trainer = users.firstWhere((u) => u.id == r.trainerId);
    if (!mounted) return;
    await AppRouter.openConversation(
      context,
      me: widget.user,
      peer: trainer,
      upcomingCall: r,
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(callRequestsProvider(widget.user.id));

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(title: const Text(AppStrings.scheduleCall)),
      body: requestsAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text(AppStrings.syncOffline)),
        data: (myRequests) {
          final pending =
              myRequests.where((r) => r.status == CallRequestStatus.pending);
          final approved =
              myRequests.where((r) => r.status == CallRequestStatus.approved);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(AppStrings.pickDay, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _days.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final d = _days[i];
                    final selected = d.day == _selectedDay.day &&
                        d.month == _selectedDay.month;
                    return WtfChip(
                      label: DateFormat('EEE d MMM').format(d),
                      selected: selected,
                      icon: Icons.calendar_today_rounded,
                      onTap: () => setState(() => _selectedDay = d),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(AppStrings.timeSlot, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _slots.map((slot) {
                  final parts = slot.split(':');
                  final dt = DateTime(
                    _selectedDay.year,
                    _selectedDay.month,
                    _selectedDay.day,
                    int.parse(parts[0]),
                    int.parse(parts[1]),
                  );
                  final past = isPastSlot(dt);
                  return Opacity(
                    opacity: past ? 0.4 : 1,
                    child: WtfChip(
                      label: slot,
                      selected: _selectedSlot == slot,
                      icon: Icons.schedule_rounded,
                      onTap: past ? () {} : () => setState(() => _selectedSlot = slot),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _noteController,
                maxLength: 140,
                decoration: const InputDecoration(
                  labelText: AppStrings.noteForTrainer,
                  hintText: AppStrings.noteHint,
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              WtfButton(
                label: AppStrings.requestCall,
                icon: Icons.video_call_rounded,
                loading: _submitting,
                onPressed: () => _submit(myRequests),
              ),
              const SizedBox(height: 32),
              Text(AppStrings.myRequests,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              if (pending.isEmpty && approved.isEmpty)
                Text(AppStrings.noRequestsYet,
                    style: Theme.of(context).textTheme.bodyMedium)
              else ...[
                ...pending.map((r) => _RequestCard(
                      title: formatDateTime(r.scheduledFor),
                      subtitle: r.note ?? AppStrings.pendingApproval,
                      status: AppStrings.pending,
                      statusColor: AppColors.warning,
                    )),
                ...approved.map((r) => _RequestCard(
                      title: formatDateTime(r.scheduledFor),
                      subtitle: 'Call approved for ${formatDateTime(r.scheduledFor)}',
                      status: canJoinCall(r.scheduledFor)
                          ? AppStrings.joinCall
                          : AppStrings.approved,
                      statusColor: AppColors.success,
                      onJoin: canJoinCall(r.scheduledFor) ? () => _openJoin(r) : null,
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    this.onJoin,
  });

  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.surfaceCard(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (onJoin != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(onPressed: onJoin, child: Text(status)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
