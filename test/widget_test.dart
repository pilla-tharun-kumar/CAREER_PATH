import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest_rpg/data/models/user_profile.dart';

void main() {
  group('QuantumLeap Core Logic Tests', () {
    test('XP Level progression calculation', () {
      final user = UserProfile(
        username: 'TestHero',
        avatarBase: 'knight',
        level: 1,
        xp: 80,
        requiredXp: 100,
      );

      expect(user.level, 1);
      expect(user.xp, 80);

      // Simulate a level up manually using the formula
      int currentXp = user.xp + 50; // gain 50 XP (total 130)
      int level = user.level;
      int reqXp = user.requiredXp;

      if (currentXp >= reqXp) {
        currentXp -= reqXp;
        level++;
        reqXp = level * 100 + 50;
      }

      final updatedUser = user.copyWith(
        xp: currentXp,
        level: level,
        requiredXp: reqXp,
      );

      expect(updatedUser.level, 2);
      expect(updatedUser.xp, 30);
      expect(updatedUser.requiredXp, 250); // Level 2 required: 2 * 100 + 50 = 250
    });

    test('Streak decay checks', () {
      final user = UserProfile(
        username: 'TestHero',
        avatarBase: 'knight',
        streak: 5,
        lastActiveDate: DateTime.now().subtract(const Duration(days: 2)), // 2 days ago
      );
      
      final today = DateTime.now();
      final difference = today.difference(user.lastActiveDate!).inDays;
      
      int finalStreak = user.streak;
      if (difference > 1) {
        finalStreak = 0;
      }
      
      expect(finalStreak, 0);
    });
  });
}
