import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../providers/user_provider.dart';

class SideQuestsScreen extends ConsumerStatefulWidget {
  const SideQuestsScreen({super.key});

  @override
  ConsumerState<SideQuestsScreen> createState() => _SideQuestsScreenState();
}

class _SideQuestsScreenState extends ConsumerState<SideQuestsScreen> {
  final _metricRowsController = TextEditingController(text: "50,000");
  final _trendController = TextEditingController(text: "unusual customer churn spike in Q2");
  final _metricOutputController = TextEditingController(text: "retaining 14% more active accounts");

  String _getLinkedInPost(String track, int unit) {
    String topic = "Data Analytics";
    String datasetName = "Superstore retail sales dataset";
    String insight = "identified key revenue-driving categories and seasonal sales patterns";

    if (track == 'SQL') {
      topic = "Advanced SQL";
      datasetName = "Netflix titles database";
      insight = "optimized nested subqueries and window rankings to segment content popularity";
    } else if (track == 'Python') {
      topic = "Python EDA";
      datasetName = "Kaggle Movie datasets";
      insight = "wrote cleaning scripts in Pandas and generated Seaborn correlation matrices to discover factor dependencies";
    } else if (track == 'BI' || track == 'Power BI' || track == 'Tableau') {
      topic = "Business Intelligence Dashboards";
      datasetName = "Superstore dataset";
      insight = "built Calculated DAX fields and connected relationship models to reveal regional ROI trends";
    }

    return "📝 Project Update: Just completed Node $unit in my $topic track! "
        "Built a detailed analytics model exploring the $datasetName. "
        "I loaded and cleaned raw rows, then $insight. "
        "Excited to continue building my portfolio. Check out my GitHub repo for the code! "
        "#LearningInPublic #DataAnalytics #SQL #Python #CareerShift";
  }

  String _getLaTeXResumeBullet(String tool, String rows, String trend, String output) {
    return "\\item Analyzed $rows+ transaction rows using \\textbf{$tool} to identify $trend, resulting in \\textbf{$output}.";
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    if (user == null) return SizedBox();

    final activeTrack = user.activeTrack;
    final currentUnit = user.currentUnit;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Header
              Text(
                'CAREER DEVELOPMENT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5,
                  color: RpgColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              // Description card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.work, color: RpgColors.secondary),
                          SizedBox(width: 12),
                          Text(
                            'Build Your Real-world Portfolio',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: RpgColors.textPrimary),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Turn your curriculum milestones directly into job search actions. Generate professional updates for LinkedIn and build ATS-friendly LaTeX resume bullet points.',
                        style: TextStyle(fontSize: 12, color: RpgColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Section: LinkedIn Content Creator
              Text(
                'LINKEDIN MILESTONE GENERATOR',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: RpgColors.primary, letterSpacing: 1),
              ),
              SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.share, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Milestone: Unit $currentUnit ($activeTrack)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: RpgColors.textPrimary),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xfff7f7f7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: RpgColors.border),
                        ),
                        child: Text(
                          _getLinkedInPost(activeTrack, currentUnit),
                          style: TextStyle(fontSize: 12, color: RpgColors.textPrimary, height: 1.4),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _getLinkedInPost(activeTrack, currentUnit)));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied post to clipboard! Share on LinkedIn.')),
                          );
                        },
                        icon: Icon(Icons.copy, size: 16, color: Colors.white),
                        label: Text('COPY POST LAYOUT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RpgColors.primary,
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Color(0xff46a302), width: 2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Section: Resume Bullet Builder
              Text(
                'RESUME STAR BULLET BUILDER (LATEX)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: RpgColors.primary, letterSpacing: 1),
              ),
              SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Input your project results to build a STAR-format LaTeX bullet point:',
                        style: TextStyle(fontSize: 12, color: RpgColors.textSecondary),
                      ),
                      SizedBox(height: 16),
                      
                      TextField(
                        controller: _metricRowsController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Data Rows / Size',
                          hintText: 'e.g., 50,000',
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      TextField(
                        controller: _trendController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Value Trend / Discovery',
                          hintText: 'e.g., regional purchase trends',
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      TextField(
                        controller: _metricOutputController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Quantified Output / Business Outcome',
                          hintText: 'e.g., optimizing stock layouts by 15%',
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      Text(
                        'Generated LaTeX Code:',
                        style: TextStyle(fontSize: 11, color: RpgColors.textPrimary, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xfff7f7f7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: RpgColors.border),
                        ),
                        child: Text(
                          _getLaTeXResumeBullet(
                            activeTrack, 
                            _metricRowsController.text, 
                            _trendController.text, 
                            _metricOutputController.text
                          ),
                          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.teal.shade800, height: 1.4),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      OutlinedButton.icon(
                        onPressed: () {
                          final latex = _getLaTeXResumeBullet(
                            activeTrack, 
                            _metricRowsController.text, 
                            _trendController.text, 
                            _metricOutputController.text
                          );
                          Clipboard.setData(ClipboardData(text: latex));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied LaTeX command to clipboard!')),
                          );
                        },
                        icon: Icon(Icons.copy, size: 16, color: RpgColors.secondary),
                        label: Text('COPY LATEX CODE'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: RpgColors.secondary, width: 2),
                          foregroundColor: RpgColors.secondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
