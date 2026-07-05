import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../core/theme.dart';
import '../providers/user_provider.dart';
import '../data/models/user_profile.dart';

class StudyResource {
  final String title;
  final String url;
  final bool isVideo;

  const StudyResource({
    required this.title,
    required this.url,
    required this.isVideo,
  });
}

class PathNode {
  final String id;
  final String title;
  final String description;
  final bool isLock;
  final String category; // 'setup' | 'excel' | 'stats' | 'sql' | 'python' | 'ml' | 'bi' | 'jobs'
  final StudyResource resource;

  const PathNode({
    required this.id,
    required this.title,
    required this.description,
    this.isLock = false,
    required this.category,
    required this.resource,
  });
}

class UnitSection {
  final int unitNumber;
  final String name;
  final String description;
  final String category;
  final List<PathNode> nodes;

  const UnitSection({
    required this.unitNumber,
    required this.name,
    required this.description,
    required this.category,
    required this.nodes,
  });
}

class LiquidScrollTreeScreen extends ConsumerStatefulWidget {
  final String title;
  final List<UnitSection> curriculum;

  const LiquidScrollTreeScreen({
    super.key,
    required this.title,
    required this.curriculum,
  });

  @override
  ConsumerState<LiquidScrollTreeScreen> createState() => _LiquidScrollTreeScreenState();
}

class _LiquidScrollTreeScreenState extends ConsumerState<LiquidScrollTreeScreen> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _mascotController;
  double _scrollSpeed = 0.0;
  double _lastScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    final delta = currentOffset - _lastScrollOffset;
    _lastScrollOffset = currentOffset;

    setState(() {
      _scrollSpeed = delta.clamp(-15.0, 15.0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mascotController.dispose();
    super.dispose();
  }



  Future<void> _launchResource(String urlString) async {
    final String? ytId = _extractYoutubeId(urlString);
    
    if (ytId != null) {
      // Show embedded YouTube player
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800, maxHeight: 600),
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: RpgColors.border, width: 2),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: YoutubeEmbedWidget(videoId: ytId)),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      return;
    }

    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw 'Could not launch $urlString';
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open embedded browser. Copied link: $urlString')),
        );
        Clipboard.setData(ClipboardData(text: urlString));
      }
    }
  }

  String? _extractYoutubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    } else if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
    }
    return null;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'setup': return Color(0xff64748b);
      case 'excel': return Color(0xff58cc02);
      case 'stats': return Color(0xff06b6d4);
      case 'sql': return Color(0xffff9600);
      case 'python': return Color(0xff1cb0f6);
      case 'ml': return Color(0xff8b5cf6);
      case 'bi': return Color(0xfff43f5e);
      case 'jobs': return Color(0xff10b981);
      default: return Color(0xff58cc02);
    }
  }

  Color _getCategoryBottomColor(String category) {
    switch (category) {
      case 'setup': return Color(0xff475569);
      case 'excel': return Color(0xff46a302);
      case 'stats': return Color(0xff0891b2);
      case 'sql': return Color(0xffd97706);
      case 'python': return Color(0xff1899d6);
      case 'ml': return Color(0xff7c3aed);
      case 'bi': return Color(0xffe11d48);
      case 'jobs': return Color(0xff059669);
      default: return Color(0xff46a302);
    }
  }

  void _showNodePopup(PathNode node, bool isCompleted) {
    final Color categoryColor = _getCategoryColor(node.category);
    final Color bottomBorderColor = _getCategoryBottomColor(node.category);

    showModalBottomSheet(
      context: context,
      backgroundColor: RpgColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    node.category.toUpperCase(),
                    style: TextStyle(color: categoryColor, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
                  ),
                  if (isCompleted)
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: RpgColors.primary, size: 18),
                        SizedBox(width: 4),
                        Text('COMPLETED', style: TextStyle(color: RpgColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                node.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: RpgColors.textPrimary),
              ),
              SizedBox(height: 8),
              Text(
                node.description,
                style: TextStyle(color: RpgColors.textSecondary, fontSize: 13),
              ),
              SizedBox(height: 24),

              StatefulBuilder(
                builder: (context, setState) {
                  bool isLaunching = false;
                  return ElevatedButton.icon(
                    onPressed: () {
                      if (isLaunching) return;
                      setState(() => isLaunching = true);
                      Navigator.pop(context);
                      _launchResource(node.resource.url);
                    },
                    icon: Icon(node.resource.isVideo ? Icons.play_circle : Icons.description, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: bottomBorderColor, width: 2),
                      ),
                    ),
                    label: Text(
                      isCompleted ? 'REVIEW STUDY MATERIAL' : 'START STUDYING',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                    ),
                  );
                }
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    if (user == null) return SizedBox();

    final currentUnit = user.currentUnit;

    return Scaffold(
      backgroundColor: RpgColors.background,
      body: Stack(
        children: [
          // Scroll tree contents
          ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24, 110, 24, 90),
            itemCount: widget.curriculum.length,
            itemBuilder: (context, unitIdx) {
              final unit = widget.curriculum[unitIdx];
              final bool isUnitUnlocked = unit.unitNumber <= currentUnit;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Unit Header Card
                  _buildUnitHeader(unit, isUnitUnlocked),
                  SizedBox(height: 24),
                  
                  // Serpentine tree nodes
                  if (isUnitUnlocked)
                    ...unit.nodes.asMap().entries.map((entry) {
                      final nodeIdx = entry.key;
                      final node = entry.value;
                      
                      final bool isCompleted = unit.unitNumber < currentUnit || 
                          (unit.unitNumber == currentUnit && nodeIdx < 1); // Mock active node progression

                      return _buildSerpentineNode(node, nodeIdx, isCompleted);
                    })
                  else
                    _buildLockedPlaceholder(unit.category),
                  
                  SizedBox(height: 20),
                ],
              );
            },
          ),

          // Top Persistent Sticky Banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildPersistentBanner(user),
          ),

          // Floating Owl Mascot overlay
          Positioned(
            bottom: 24,
            right: 16,
            child: _buildFloatingMascot(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersistentBanner(UserProfile user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: RpgColors.cardBg,
        border: Border(bottom: BorderSide(color: RpgColors.border, width: 2)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Roadmap Track Indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: RpgColors.primary.withValues(alpha: 0.1),
                border: Border.all(color: RpgColors.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.map, color: RpgColors.primary, size: 14),
                  SizedBox(width: 4),
                  Text(
                    widget.title.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: RpgColors.primary),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),

            // Progress Bar of current unit
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.35, 
                  backgroundColor: Color(0xffe5e5e5),
                  color: RpgColors.primary,
                  minHeight: 12,
                ),
              ),
            ),
            SizedBox(width: 16),

            // Streak Flame
            Row(
              children: [
                Icon(Icons.local_fire_department, color: RpgColors.accent, size: 22),
                SizedBox(width: 2),
                Text(
                  '${user.streak}', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: RpgColors.accent),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildUnitHeader(UnitSection unit, bool isUnlocked) {
    final Color bannerColor = isUnlocked ? _getCategoryColor(unit.category) : Color(0xffcccccc);
    final Color bottomBorderColor = isUnlocked ? _getCategoryBottomColor(unit.category) : Color(0xffb0b0b0);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border(bottom: BorderSide(color: bottomBorderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UNIT ${unit.unitNumber} • ${unit.category.toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: RpgColors.cardBg,
                  letterSpacing: 1.2,
                ),
              ),
              if (!isUnlocked)
                Icon(Icons.lock, color: RpgColors.cardBg, size: 16),
            ],
          ),
          SizedBox(height: 8),
          Text(
            unit.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: RpgColors.cardBg,
            ),
          ),
          SizedBox(height: 6),
          Text(
            unit.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSerpentineNode(PathNode node, int index, bool isCompleted) {
    final double offset = sin(index * 1.5) * 60;
    
    // Antigravity physical squish factor calculations on scrolling velocity
    final double squishX = 1.0 - (_scrollSpeed.abs() * 0.015);
    final double squishY = 1.0 + (_scrollSpeed.abs() * 0.012);

    final Color nodeColor = _getCategoryColor(node.category);
    final Color bottomBorderColor = _getCategoryBottomColor(node.category);

    return Align(
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(offset, 0),
        child: Padding(
          padding: EdgeInsets.only(bottom: 24.0),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(squishX, squishY, 1.0),
            child: GestureDetector(
              onTap: () => _showNodePopup(node, isCompleted),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? nodeColor : RpgColors.cardBg,
                  border: Border.all(
                    color: isCompleted ? bottomBorderColor : RpgColors.border,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isCompleted 
                          ? bottomBorderColor.withValues(alpha: 0.2) 
                          : Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Center(
                  child: Icon(
                    isCompleted ? Icons.check : Icons.star,
                    color: isCompleted ? Colors.white : nodeColor,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockedPlaceholder(String category) {
    return Column(
      children: List.generate(2, (index) {
        final double offset = sin(index * 1.5) * 60;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xfff3f4f6),
                border: Border.all(color: RpgColors.border, width: 4),
              ),
              child: Center(
                child: Icon(Icons.lock, color: RpgColors.textSecondary, size: 24),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFloatingMascot() {
    return AnimatedBuilder(
      animation: _mascotController,
      builder: (context, child) {
        final double bobOffset = sin(_mascotController.value * pi * 2) * 6;
        final double angle = _scrollSpeed * 0.02;

        return Transform.translate(
          offset: Offset(0, bobOffset),
          child: Transform.rotate(
            angle: angle,
            child: child,
          ),
        );
      },
      child: Tooltip(
        message: 'Duo Study Assistant',
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: RpgColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: RpgColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              )
            ],
            border: Border.all(color: RpgColors.cardBg, width: 3),
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(40, 40),
              painter: OwlFacePainter(),
            ),
          ),
        ),
      ),
    );
  }
}

// Flat Duolingo-style Green Owl face Painter
class OwlFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final facePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = RpgColors.textPrimary;
    final beakPaint = Paint()..color = RpgColors.accent;

    // Draw white eyes base
    canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.45), 9, facePaint);
    canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.45), 9, facePaint);

    // Draw dark pupils
    canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.45), 4, pupilPaint);
    canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.45), 4, pupilPaint);

    // Draw orange beak (triangle)
    final beakPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.48)
      ..lineTo(size.width * 0.42, size.height * 0.6)
      ..lineTo(size.width * 0.58, size.height * 0.6)
      ..close();
    canvas.drawPath(beakPath, beakPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class YoutubeEmbedWidget extends StatefulWidget {
  final String videoId;
  const YoutubeEmbedWidget({super.key, required this.videoId});

  @override
  State<YoutubeEmbedWidget> createState() => _YoutubeEmbedWidgetState();
}

class _YoutubeEmbedWidgetState extends State<YoutubeEmbedWidget> {
  late YoutubePlayerController _controller;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );

    // Listen for video completion to auto-close the dialog
    _subscription = _controller.listen((event) {
      if (event.playerState == PlayerState.ended) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.pauseVideo();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(controller: _controller);
  }
}
