import 'user.dart';

/// Used when sync server is offline so onboarding still works.
class SeedData {
  static const trainers = [
    User(
      id: 'trainer_aarav',
      role: UserRole.trainer,
      name: 'Aarav (Lead Trainer)',
      email: 'aarav@wtf.fitness',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Aarav',
    ),
  ];

  static const memberDk = User(
    id: 'member_dk',
    role: UserRole.member,
    name: 'DK',
    email: 'dk@wtf.fitness',
    avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=DK',
    assignedTrainerId: 'trainer_aarav',
  );
}
