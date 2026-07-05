import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/services/mongo_sync_service.dart';
import '../data/models/user_profile.dart';

class UserProfileNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() {
    final box = Hive.box<UserProfile>('profile');
    if (box.isNotEmpty) {
      final user = box.get('current_user');
      if (user != null) {
        Future.microtask(() => checkStreakDecay());
        return user;
      }
    }
    
    // Create a default user profile since we skipped onboarding
    final defaultUser = UserProfile(
      username: 'Guest',
      avatarBase: 'knight',
    );
    
    Future.microtask(() => box.put('current_user', defaultUser));
    return defaultUser;
  }

  Future<void> checkStreakDecay() async {
    if (state == null || state!.lastActiveDate == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActiveDay = DateTime(state!.lastActiveDate!.year, state!.lastActiveDate!.month, state!.lastActiveDate!.day);
    final difference = today.difference(lastActiveDay).inDays;

    if (difference > 1) {
      if (state!.streakFreezeCount > 0) {
        state = state!.copyWith(
          streakFreezeCount: state!.streakFreezeCount - 1,
          lastActiveDate: today.subtract(const Duration(days: 1)),
        );
      } else {
        state = state!.copyWith(streak: 0);
      }
      await Hive.box<UserProfile>('profile').put('current_user', state!);
      _syncToRemote();
    }
  }

  Future<void> addXp(int amount, {required void Function(int newLevel) onLevelUp}) async {
    if (state == null) return;
    
    int newXp = state!.xp + amount;
    int newLevel = state!.level;
    int newRequiredXp = state!.requiredXp;
    bool leveledUp = false;

    while (newXp >= newRequiredXp) {
      newXp -= newRequiredXp;
      newLevel++;
      newRequiredXp = newLevel * 100 + 50; // Progression scale
      leveledUp = true;
    }

    String newTitle = state!.title;
    if (leveledUp) {
      newTitle = UserProfile.getCharacterTitle(state!.avatarBase, newLevel);
    }

    state = state!.copyWith(
      xp: newXp,
      level: newLevel,
      requiredXp: newRequiredXp,
      title: newTitle,
    );
    await Hive.box<UserProfile>('profile').put('current_user', state!);
    _syncToRemote();

    if (leveledUp) {
      onLevelUp(newLevel);
    }
  }

  Future<void> addCoins(int amount) async {
    if (state == null) return;
    state = state!.copyWith(coins: state!.coins + amount);
    await Hive.box<UserProfile>('profile').put('current_user', state!);
    _syncToRemote();
  }

  Future<bool> deductCoins(int amount) async {
    if (state == null) return false;
    if (state!.coins < amount) return false;
    
    state = state!.copyWith(coins: state!.coins - amount);
    await Hive.box<UserProfile>('profile').put('current_user', state!);
    _syncToRemote();
    return true;
  }

  Future<void> equipItem(String itemId, String type) async {
    if (state == null) return;

    if (type == 'outfit') {
      state = state!.copyWith(equippedOutfit: itemId);
    } else if (type == 'accessory') {
      state = state!.copyWith(equippedAccessory: itemId);
    } else if (type == 'theme') {
      state = state!.copyWith(equippedBackground: itemId);
    }
    await Hive.box<UserProfile>('profile').put('current_user', state!);
    _syncToRemote();
  }

  Future<void> updateStreaks(String category) async {
    if (state == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int generalStreak = state!.streak;
    int codingStreak = state!.codingStreak;
    int fitnessStreak = state!.fitnessStreak;
    int readingStreak = state!.readingStreak;

    final lastActive = state!.lastActiveDate;
    
    if (lastActive == null) {
      generalStreak = 1;
    } else {
      final lastActiveDay = DateTime(lastActive.year, lastActive.month, lastActive.day);
      final difference = today.difference(lastActiveDay).inDays;

      if (difference == 1) {
        generalStreak += 1;
      } else if (difference > 1) {
        generalStreak = 1;
      }
    }

    if (category == 'coding') {
      codingStreak += 1;
    } else if (category == 'fitness') {
      fitnessStreak += 1;
    } else if (category == 'learning') {
      readingStreak += 1;
    }

    state = state!.copyWith(
      streak: generalStreak,
      codingStreak: codingStreak,
      fitnessStreak: fitnessStreak,
      readingStreak: readingStreak,
      lastActiveDate: today,
    );
    
    await Hive.box<UserProfile>('profile').put('current_user', state!);
    _syncToRemote();
  }

  // Award achievements rewards
  Future<void> claimAchievementReward(int amount) async {
    await addCoins(amount);
  }

  Future<void> deductHeart() async {
    if (state == null) return;
    if (state!.hearts > 0) {
      state = state!.copyWith(hearts: state!.hearts - 1);
      await Hive.box<UserProfile>('profile').put('current_user', state!);
      _syncToRemote();
    }
  }

  Future<void> restoreHeart() async {
    if (state == null) return;
    if (state!.hearts < 5) {
      state = state!.copyWith(hearts: state!.hearts + 1);
      await Hive.box<UserProfile>('profile').put('current_user', state!);
      _syncToRemote();
    }
  }

  Future<bool> buyStreakFreeze() async {
    if (state == null) return false;
    if (state!.streakFreezeCount >= 2) return false;
    if (state!.coins < 500) return false;

    state = state!.copyWith(
      coins: state!.coins - 500,
      streakFreezeCount: state!.streakFreezeCount + 1,
    );
    await Hive.box<UserProfile>('profile').put('current_user', state!);
    _syncToRemote();
    return true;
  }

  Future<void> setActiveTrack(String track) async {
    if (state == null) return;
    state = state!.copyWith(activeTrack: track, currentUnit: 1);
    await Hive.box<UserProfile>('profile').put('current_user', state!);
    _syncToRemote();
  }

  Future<void> incrementUnit() async {
    if (state == null) return;
    state = state!.copyWith(currentUnit: state!.currentUnit + 1);
    await Hive.box<UserProfile>('profile').put('current_user', state!);
    _syncToRemote();
  }

  Future<void> updateUsernameAndAvatar(String username, String avatarBase) async {
    if (state == null) return;
    final newTitle = UserProfile.getCharacterTitle(avatarBase, state!.level);
    state = state!.copyWith(
      username: username,
      avatarBase: avatarBase,
      title: newTitle,
    );
    await Hive.box<UserProfile>('profile').put('current_user', state!);
    _syncToRemote();
  }

  void _syncToRemote() {
    if (state == null) return;
    MongoSyncService.syncDocument(
      collection: "profiles",
      documentId: "current_user",
      data: {
        "username": state!.username,
        "level": state!.level,
        "xp": state!.xp,
        "requiredXp": state!.requiredXp,
        "coins": state!.coins,
        "title": state!.title,
        "avatarBase": state!.avatarBase,
        "equippedOutfit": state!.equippedOutfit,
        "equippedAccessory": state!.equippedAccessory,
        "equippedBackground": state!.equippedBackground,
        "streak": state!.streak,
        "lastActiveDate": state!.lastActiveDate?.toIso8601String(),
        "codingStreak": state!.codingStreak,
        "fitnessStreak": state!.fitnessStreak,
        "readingStreak": state!.readingStreak,
        "hearts": state!.hearts,
        "streakFreezeCount": state!.streakFreezeCount,
        "activeTrack": state!.activeTrack,
        "currentUnit": state!.currentUnit,
      },
    );
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile?>(UserProfileNotifier.new);
