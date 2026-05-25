import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

import 'guru_home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  final _nameController = TextEditingController(text: 'DK');
  String? _trainerId = 'trainer_aarav';
  List<User> _trainers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTrainers();
  }

  Future<void> _loadTrainers() async {
    try {
      final users = await ref.read(syncClientProvider).fetchUsers();
      if (!mounted) return;
      setState(() {
        _trainers = users.where((u) => u.role == UserRole.trainer).toList();
        if (_trainers.isEmpty) _trainers = SeedData.trainers;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _trainers = SeedData.trainers;
        _loading = false;
      });
    }
  }

  Future<void> _finish() async {
    final user = User(
      id: 'member_dk',
      role: UserRole.member,
      name: _nameController.text.trim().isEmpty
          ? 'DK'
          : _nameController.text.trim(),
      email: 'dk@wtf.fitness',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=DK',
      assignedTrainerId: _trainerId,
    );
    await widget.auth.completeOnboarding(user);
    if (!mounted) return;
    AppRouter.replace(context, GuruHomeScreen(user: user, auth: widget.auth));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 4,
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: i <= _page ? primary : AppColors.neutral200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _OnboardingSlide(
                    icon: Icons.fitness_center_rounded,
                    title: AppStrings.onboardingTitle1,
                    body: AppStrings.onboardingBody1,
                    accent: primary,
                  ),
                  _OnboardingSlide(
                    icon: Icons.videocam_rounded,
                    title: AppStrings.onboardingTitle2,
                    body: AppStrings.onboardingBody2,
                    accent: primary,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppStrings.createProfile,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.almostReady,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.yourName,
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppStrings.chooseTrainer,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 12),
                        if (_loading)
                          const Center(child: CircularProgressIndicator())
                        else
                          Expanded(
                            child: ListView(
                              children: _trainers
                                  .map(
                                    (t) => _TrainerCard(
                                      trainer: t,
                                      selected: _trainerId == t.id,
                                      onTap: () =>
                                          setState(() => _trainerId = t.id),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_page > 0)
                    WtfButton(
                      label: AppStrings.back,
                      variant: WtfButtonVariant.ghost,
                      expand: false,
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      ),
                    ),
                  const Spacer(),
                  SizedBox(
                    width: 168,
                    child: WtfButton(
                      label: _page < 2 ? AppStrings.next : AppStrings.getStarted,
                      icon: Icons.arrow_forward_rounded,
                      expand: true,
                      onPressed: _page < 2
                          ? () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              )
                          : _finish,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 44, color: accent),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  const _TrainerCard({
    required this.trainer,
    required this.selected,
    required this.onTap,
  });

  final User trainer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? primary.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? primary : AppColors.neutral200,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                WtfAvatar(url: trainer.avatarUrl, radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.name,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        trainer.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
