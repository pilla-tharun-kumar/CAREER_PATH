import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';
import '../core/config.dart';
import '../providers/user_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/quest_provider.dart';
import '../widgets/avatar_painter.dart';
import '../data/services/mongo_sync_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final achievements = ref.watch(achievementProvider);
    final quests = ref.watch(questProvider);

    if (user == null) return const SizedBox();

    final completedCount = quests.where((q) => q.isCompleted).length;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Character Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    AvatarWidget(
                      avatarBase: user.avatarBase,
                      outfitId: user.equippedOutfit,
                      accessoryId: user.equippedAccessory,
                      size: 110,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.username.toUpperCase(),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.title,
                      style: const TextStyle(color: RpgColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: RpgColors.border),
                    const SizedBox(height: 12),
                    
                    // General Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatMetric('QUESTS CLEARED', '$completedCount', Icons.done_all, RpgColors.success),
                        _buildStatMetric('MAIN STREAK', '${user.streak} days', Icons.local_fire_department, RpgColors.secondary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Streaks breakdown
            Text(
              'DOMAINS CONSISTENCY STREAKS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14, letterSpacing: 1, color: RpgColors.primary),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    _buildStreakRow('Coding Streaks', '${user.codingStreak} days', Icons.code, Colors.cyan),
                    const Divider(color: RpgColors.border),
                    _buildStreakRow('Fitness Streaks', '${user.fitnessStreak} days', Icons.fitness_center, Colors.green),
                    const Divider(color: RpgColors.border),
                    _buildStreakRow('Learning Streaks', '${user.readingStreak} days', Icons.menu_book, Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const CloudConnectionCard(),
            const SizedBox(height: 24),

            // Achievements section
            Text(
              'HALL OF HEROIC ACHIEVEMENTS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14, letterSpacing: 1, color: RpgColors.primary),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final ach = achievements[index];
                final isUnlocked = ach.isUnlocked;

                return Card(
                  color: isUnlocked ? RpgColors.cardBg : RpgColors.cardBg.withOpacity(0.4),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: isUnlocked 
                          ? Border.all(color: RpgColors.accent.withAlpha(150), width: 1.5) 
                          : Border.all(color: RpgColors.border),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isUnlocked ? Icons.workspace_premium : Icons.lock_outline,
                          color: isUnlocked ? RpgColors.accent : Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ach.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isUnlocked ? Colors.white : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isUnlocked 
                              ? 'CLEARED! (+50G)' 
                              : '${ach.currentValue} / ${ach.targetValue} steps',
                          style: TextStyle(
                            fontSize: 9,
                            color: isUnlocked ? RpgColors.success : RpgColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: RpgColors.textSecondary, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStreakRow(String title, String val, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            val,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class CloudConnectionCard extends StatefulWidget {
  const CloudConnectionCard({super.key});

  @override
  State<CloudConnectionCard> createState() => _CloudConnectionCardState();
}

class _CloudConnectionCardState extends State<CloudConnectionCard> {
  bool _isTesting = false;
  bool _isSyncing = false;
  bool? _testSuccess;
  int _pendingCount = MongoSyncService.pendingSyncsCount;

  void _testPing() async {
    setState(() {
      _isTesting = true;
      _testSuccess = null;
    });
    final success = await MongoSyncService.testConnection();
    if (mounted) {
      setState(() {
        _isTesting = false;
        _testSuccess = success;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? '✅ Cloud Database connection ping successful!' 
                : '❌ Connection failed. Check MongoDB URI / network status.',
          ),
          backgroundColor: success ? RpgColors.success : Colors.red,
        ),
      );
    }
  }

  void _syncQueue() async {
    setState(() {
      _isSyncing = true;
    });
    
    await MongoSyncService.processOfflineQueue();
    
    if (mounted) {
      setState(() {
        _isSyncing = false;
        _pendingCount = MongoSyncService.pendingSyncsCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 Offline synchronization queue processed!'),
          backgroundColor: RpgColors.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final isFirebaseActive = RpgConfig.isFirebaseEnabled && firebaseUser != null;
    final isMongoActive = RpgConfig.isMongoSyncEnabled;
    
    // Mask MongoDB URI password: mongodb+srv://user:pass@host/db -> mongodb+srv://user:***@host/db
    String maskedUri = RpgConfig.mongoUri;
    try {
      final uriParts = RpgConfig.mongoUri.split('@');
      if (uriParts.length == 2) {
        final credentialParts = uriParts[0].split(':');
        if (credentialParts.length == 3) {
          maskedUri = "${credentialParts[0]}:${credentialParts[1]}:******@${uriParts[1]}";
        }
      }
    } catch (_) {}

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.sync_alt, color: RpgColors.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'CLOUD SYNC & BACKEND STATUS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Firebase authentication status
            _buildConnectionRow(
              title: 'FIREBASE AUTH SERVICE',
              subtitle: isFirebaseActive ? 'Connected as: ${firebaseUser.email}' : 'Mock Auth Mode (offline)',
              isActive: isFirebaseActive,
              icon: Icons.vpn_key_outlined,
            ),
            const SizedBox(height: 12),
            const Divider(color: RpgColors.border, height: 1),
            const SizedBox(height: 12),

            // MongoDB Sync status
            _buildConnectionRow(
              title: 'MONGODB ATLAS CLUSTER SYNC',
              subtitle: _pendingCount > 0 
                  ? 'Offline: $_pendingCount local tasks pending sync' 
                  : (isMongoActive ? 'Synced to Cluster: ...${maskedUri.substring(maskedUri.indexOf('@') + 1)}' : 'Disabled (Local Cache Only)'),
              isActive: isMongoActive && _pendingCount == 0,
              isWarning: _pendingCount > 0,
              icon: Icons.storage_outlined,
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTesting ? null : _testPing,
                    icon: _isTesting 
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(
                            _testSuccess == null 
                                ? Icons.radar 
                                : (_testSuccess! ? Icons.check_circle : Icons.error),
                            size: 16,
                          ),
                    label: const Text('TEST PING', style: TextStyle(fontSize: 11, letterSpacing: 0.5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _testSuccess == null
                          ? RpgColors.cardBg
                          : (_testSuccess! ? RpgColors.success : Colors.red),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing || !isMongoActive ? null : _syncQueue,
                    icon: _isSyncing 
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.cloud_upload_outlined, size: 16),
                    label: const Text('FORCE SYNC', style: TextStyle(fontSize: 11, letterSpacing: 0.5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RpgColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionRow({
    required String title,
    required String subtitle,
    required bool isActive,
    bool isWarning = false,
    required IconData icon,
  }) {
    Color statusColor = isActive 
        ? RpgColors.success 
        : (isWarning ? Colors.amber : RpgColors.textSecondary);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: RpgColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: RpgColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Pulsing / static dot
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor,
            boxShadow: [
              if (isActive || isWarning)
                BoxShadow(
                  color: statusColor.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 2,
                )
            ]
          ),
        )
      ],
    );
  }
}
