import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../data/models/user_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Color _getAvatarColor(String base) {
    switch (base) {
      case 'setup': return Color(0xff64748b).withValues(alpha: 0.1);
      case 'excel': return Color(0xff58cc02).withValues(alpha: 0.1);
      case 'stats': return Color(0xff06b6d4).withValues(alpha: 0.1);
      case 'sql': return Color(0xffff9600).withValues(alpha: 0.1);
      case 'python': return Color(0xff1cb0f6).withValues(alpha: 0.1);
      case 'ml': return Color(0xff8b5cf6).withValues(alpha: 0.1);
      case 'bi': return Color(0xfff43f5e).withValues(alpha: 0.1);
      case 'jobs': return Color(0xff10b981).withValues(alpha: 0.1);
      default: return Color(0xff1cb0f6).withValues(alpha: 0.1);
    }
  }

  Color _getAvatarBorderColor(String base) {
    switch (base) {
      case 'setup': return Color(0xff64748b);
      case 'excel': return Color(0xff58cc02);
      case 'stats': return Color(0xff06b6d4);
      case 'sql': return Color(0xffff9600);
      case 'python': return Color(0xff1cb0f6);
      case 'ml': return Color(0xff8b5cf6);
      case 'bi': return Color(0xfff43f5e);
      case 'jobs': return Color(0xff10b981);
      default: return Color(0xff1cb0f6);
    }
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, UserProfile user) {
    final nameController = TextEditingController(text: user.username);
    String selectedColor = user.avatarBase;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('EDIT PROFILE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: RpgColors.textPrimary)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'STUDENT NAME',
                        hintText: 'Enter name',
                      ),
                      maxLength: 16,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'AVATAR THEME COLOR',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: RpgColors.textSecondary, letterSpacing: 0.5),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['excel', 'python', 'sql', 'bi', 'setup'].map((colorKey) {
                        Color bubbleColor;
                        switch (colorKey) {
                          case 'setup': bubbleColor = Color(0xff64748b); break;
                          case 'excel': bubbleColor = Color(0xff58cc02); break;
                          case 'sql': bubbleColor = Color(0xffff9600); break;
                          case 'python': bubbleColor = Color(0xff1cb0f6); break;
                          case 'bi': bubbleColor = Color(0xfff43f5e); break;
                          default: bubbleColor = Color(0xff1cb0f6);
                        }

                        final isSel = selectedColor == colorKey;

                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColor = colorKey;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: bubbleColor,
                              border: Border.all(
                                color: isSel ? Colors.black : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: isSel
                                ? Icon(Icons.check, color: Colors.white, size: 18)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('CANCEL', style: TextStyle(color: RpgColors.textSecondary, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newName = nameController.text.trim();
                    if (newName.isNotEmpty) {
                      ref.read(userProfileProvider.notifier).updateUsernameAndAvatar(newName, selectedColor);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RpgColors.primary,
                    side: BorderSide(color: Color(0xff46a302), width: 2),
                  ),
                  child: Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);

    if (user == null) return SizedBox();

    final String initial = user.username.isNotEmpty ? user.username[0].toUpperCase() : 'G';
    final avatarColor = _getAvatarColor(user.avatarBase);
    final avatarBorder = _getAvatarBorderColor(user.avatarBase);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header title
              Text(
                'STUDENT PROFILE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5,
                  color: RpgColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              // Duolingo-Style Flat Profile Card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: RpgColors.border, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xffe5e5e5),
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Circular Avatar Initial with Edit Overlay
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _showEditProfileDialog(context, ref, user),
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: avatarColor,
                              border: Border.all(color: avatarBorder, width: 3),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: avatarBorder,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showEditProfileDialog(context, ref, user),
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Icon(Icons.edit, size: 14, color: RpgColors.textPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.username.toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: RpgColors.textPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _showEditProfileDialog(context, ref, user),
                          child: Icon(Icons.edit_note, color: RpgColors.secondary, size: 20),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    
                    Text(
                      'LEVEL ${user.level} • ${user.title.toUpperCase()}',
                      style: TextStyle(
                        color: avatarBorder,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Learning Statistics section
              Text(
                'LEARNING STATISTICS',
                style: TextStyle(fontSize: 11, letterSpacing: 1, color: RpgColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'STREAK',
                      '${user.streak} DAYS',
                      Icons.local_fire_department,
                      RpgColors.accent,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'TOTAL XP',
                      '${user.xp} XP',
                      Icons.bolt,
                      RpgColors.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
              Text(
                'APPEARANCE',
                style: TextStyle(fontSize: 11, letterSpacing: 1, color: RpgColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: RpgColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: RpgColors.border, width: 2),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(fontWeight: FontWeight.bold, color: RpgColors.textPrimary),
                  ),
                  subtitle: Text(
                    'Professional dark aesthetic',
                    style: TextStyle(color: RpgColors.textSecondary, fontSize: 12),
                  ),
                  secondary: Icon(Icons.dark_mode, color: RpgColors.primary),
                  value: ref.watch(isDarkModeProvider),
                  activeThumbColor: RpgColors.primary,
                  onChanged: (bool val) {
                    ref.read(isDarkModeProvider.notifier).setDarkMode(val);
                  },
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RpgColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xffe5e5e5),
            offset: Offset(0, 3),
            blurRadius: 0,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: RpgColors.textPrimary),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: RpgColors.textSecondary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
