import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/user_provider.dart';
import '../data/curriculum_data.dart';
import 'liquid_scroll_tree_screen.dart';
import 'side_quests_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    LiquidScrollTreeScreen(title: 'Data Analyst', curriculum: CurriculumData.dataAnalystCurriculum),
    LiquidScrollTreeScreen(title: 'Placement', curriculum: CurriculumData.placementCurriculum),
    const SideQuestsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);

    if (user == null) {
      return Scaffold(
        backgroundColor: RpgColors.background,
        body: Center(child: CircularProgressIndicator(color: RpgColors.primary)),
      );
    }

    final backgroundDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [RpgColors.background, RpgColors.background.withValues(alpha: 0.95), RpgColors.background],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );

    return Container(
      decoration: backgroundDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _tabs[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: RpgColors.cardBg,
          selectedItemColor: RpgColors.primary,
          unselectedItemColor: RpgColors.textSecondary,
          selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.school_outlined), activeIcon: Icon(Icons.school), label: 'Learn'),
            BottomNavigationBarItem(icon: Icon(Icons.business_center_outlined), activeIcon: Icon(Icons.business_center), label: 'Placement'),
            BottomNavigationBarItem(icon: Icon(Icons.work_outline), activeIcon: Icon(Icons.work), label: 'Career'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
