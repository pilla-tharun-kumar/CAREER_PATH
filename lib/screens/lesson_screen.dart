import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../providers/user_provider.dart';
import '../data/services/telemetry_service.dart';

class LessonQuestion {
  final String id;
  final String type; // 'multiple_choice' | 'visual_match' | 'syntax_scramble' | 'keypad' | 'slider_math'
  final String phase; // 'phase_0' | 'phase_1' | 'phase_2' | 'phase_3'
  final String prompt;
  final List<String> options;
  final dynamic answer;
  final String successExplanation;
  final String failureTip;

  LessonQuestion({
    required this.id,
    required this.type,
    required this.phase,
    required this.prompt,
    required this.options,
    required this.answer,
    required this.successExplanation,
    required this.failureTip,
  });
}

class LessonScreen extends ConsumerStatefulWidget {
  final String nodeId;
  final String nodeTitle;

  const LessonScreen({
    super.key,
    required this.nodeId,
    required this.nodeTitle,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  late List<LessonQuestion> _questions;
  int _currentQuestionIndex = 0;
  bool _isAnswerChecked = false;
  bool _isCorrect = false;
  DateTime _startTime = DateTime.now();
  bool _hasFailedCurrentQuestion = false;

  // User input variables
  String? _selectedMcOption;
  List<String> _scrambledSelection = [];
  final _keypadController = TextEditingController();
  double _sliderValue = 0.5;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _loadQuestions();
  }

  void _loadQuestions() {
    // Generate questions matching DataAnalyst.html curriculum phases
    _questions = [
      if (widget.nodeId == 'node_1.1')
        LessonQuestion(
          id: 'node_1.1_q1',
          type: 'multiple_choice',
          phase: 'phase_1',
          prompt: 'Why would VLOOKUP fail if the lookup value is in the 3rd column of the target range?',
          options: [
            'It only searches the left-most column of the table.',
            'It cannot handle numeric lookups.',
            'The target column index must be a negative integer.',
            'The lookup range must always reside in a separate file.'
          ],
          answer: 'It only searches the left-most column of the table.',
          successExplanation: 'VLOOKUP is structurally designed to only search the first column of the reference table array.',
          failureTip: 'Recall Excel lookup directional constraints: VLOOKUP scans left-to-right from column 1.',
        ),
      if (widget.nodeId == 'node_1.2')
        LessonQuestion(
          id: 'node_1.2_q1',
          type: 'syntax_scramble',
          phase: 'phase_1',
          prompt: 'Reconstruct the Excel formula to sum D2:D100 values where C2:C100 exceeds 1000:',
          options: ['SUMIF(', 'C2:C100, ', '">1000", ', 'D2:D100)'],
          answer: ['SUMIF(', 'C2:C100, ', '">1000", ', 'D2:D100)'],
          successExplanation: 'SUMIF checks criteria in range 1 (C2:C100) and sums matches in range 2 (D2:D100).',
          failureTip: 'Excel Syntax: SUMIF(criteria_range, criteria, [sum_range])',
        ),
      if (widget.nodeId == 'node_2.1')
        LessonQuestion(
          id: 'node_2.1_q1',
          type: 'multiple_choice',
          phase: 'phase_1',
          prompt: 'Which dataset exhibits a standard deviation closest to zero?',
          options: [
            'Dataset A: customer purchase history showing zero variance [\$10, \$10, \$10]',
            'Dataset B: normal distribution curve with narrow spread [\$5, \$10, \$15]',
            'Dataset C: broad distribution curve with wide spread [\$1, \$10, \$100]',
            'Dataset D: outlier skewed curve [\$10, \$10, \$1000]'
          ],
          answer: 'Dataset A: customer purchase history showing zero variance [\$10, \$10, \$10]',
          successExplanation: 'Standard deviation measures variance spread. A dataset with zero variance has standard deviation of 0.',
          failureTip: 'Standard deviation calculations represent distances from the mean average.',
        ),
      if (widget.nodeId == 'node_2.2')
        LessonQuestion(
          id: 'node_2.2_q1',
          type: 'visual_match',
          phase: 'phase_1',
          prompt: 'Select the visual mapping for a Left-Skewed distribution:',
          options: [
            'Right-Skewed (tail on right side)',
            'Left-Skewed (tail on left side)',
            'Normal Distribution Bell Curve',
            'Uniform Distribution'
          ],
          answer: 'Left-Skewed (tail on left side)',
          successExplanation: 'Left skewed curves display a long tail stretching to the left, meaning Mean < Median.',
          failureTip: 'Left-skewed curves drag the tail towards smaller values (the left).',
        ),
      if (widget.nodeId == 'node_2.3')
        LessonQuestion(
          id: 'node_2.3_q1',
          type: 'multiple_choice',
          phase: 'phase_1',
          prompt: 'A marketing experiment reports a p-value of 0.03. What does this mean for our business?',
          options: [
            'There is a 3% probability that the observed sales lift occurred purely due to random chance.',
            'The campaign caused a 3% decrease in overall sales performance.',
            'We must reject the campaign since the error margin is 3%.',
            'There is a 97% chance that the experiment is completely invalid.'
          ],
          answer: 'There is a 3% probability that the observed sales lift occurred purely due to random chance.',
          successExplanation: 'A p-value <= 0.05 indicates statistical significance, meaning the null hypothesis is rejected.',
          failureTip: 'p-value measures the probability of obtaining result variations by random chance.',
        ),
      if (widget.nodeId == 'node_3.1')
        LessonQuestion(
          id: 'node_3.1_q1',
          type: 'syntax_scramble',
          phase: 'phase_1',
          prompt: 'Reconstruct the SQL query to select active users from the transactions table:',
          options: ['SELECT user_id ', 'FROM transactions ', 'WHERE status = ', "'active'"],
          answer: ['SELECT user_id ', 'FROM transactions ', 'WHERE status = ', "'active'"],
          successExplanation: 'Active users are filtered by matching the status column using WHERE conditions.',
          failureTip: 'SQL Structure: SELECT column FROM table WHERE condition;',
        ),
      if (widget.nodeId == 'node_3.2')
        LessonQuestion(
          id: 'node_3.2_q1',
          type: 'multiple_choice',
          phase: 'phase_1',
          prompt: 'Which SQL JOIN retrieves only rows that have matching values in both tables?',
          options: [
            'INNER JOIN',
            'LEFT JOIN',
            'FULL OUTER JOIN',
            'CROSS JOIN'
          ],
          answer: 'INNER JOIN',
          successExplanation: 'INNER JOIN returns intersection rows matching criteria keys across both datasets.',
          failureTip: 'Intersection operations match keys in both tables.',
        ),
      if (widget.nodeId == 'node_3.3')
        LessonQuestion(
          id: 'node_3.3_q1',
          type: 'syntax_scramble',
          phase: 'phase_1',
          prompt: 'Complete the rank query using window partition functions:',
          options: ['SELECT rank() ', 'OVER (PARTITION BY ', 'region ORDER BY ', 'sales DESC)'],
          answer: ['SELECT rank() ', 'OVER (PARTITION BY ', 'region ORDER BY ', 'sales DESC)'],
          successExplanation: 'OVER partition functions isolate calculations inside separate regional rows.',
          failureTip: 'Rank functions OVER partitions order groups separately.',
        ),
      if (widget.nodeId == 'node_4.1')
        LessonQuestion(
          id: 'node_4.1_q1',
          type: 'syntax_scramble',
          phase: 'phase_2',
          prompt: 'Reconstruct the Python key-value list lookup for the language "Python":',
          options: ['skills = {"lang": ', '["Python", "SQL"]}', 'print(skills', '["lang"][0])'],
          answer: ['skills = {"lang": ', '["Python", "SQL"]}', 'print(skills', '["lang"][0])'],
          successExplanation: 'Retrieving dictionary key values requires calling the dictionary name followed by the key and index brackets.',
          failureTip: 'Recall dict access format: dictName[keyName][indexValue]',
        ),
      if (widget.nodeId == 'node_4.2')
        LessonQuestion(
          id: 'node_4.2_q1',
          type: 'multiple_choice',
          phase: 'phase_2',
          prompt: 'Which Pandas DataFrame method is equivalent to an Excel VLOOKUP?',
          options: [
            'df.merge(how="left")',
            'df.groupby()',
            'df.fillna()',
            'df.drop_duplicates()'
          ],
          answer: 'df.merge(how="left")',
          successExplanation: 'A left merge merges two DataFrames based on matching keys, which acts exactly like mapping columns via VLOOKUP.',
          failureTip: 'Joining datasets on matching rows is a merge operation.',
        ),
      if (widget.nodeId == 'node_5.1')
        LessonQuestion(
          id: 'node_5.1_q1',
          type: 'multiple_choice',
          phase: 'phase_2',
          prompt: 'Which chart type is best suited to check the relationship between house prices and square footage?',
          options: [
            'Scatter plot',
            'Box plot',
            'Stacked bar chart',
            'Histogram'
          ],
          answer: 'Scatter plot',
          successExplanation: 'Scatter plots visualize correlations between two continuous numerical variables.',
          failureTip: 'Think about mapping points across two numeric scales.',
        ),
      if (widget.nodeId == 'node_5.2')
        LessonQuestion(
          id: 'node_5.2_q1',
          type: 'multiple_choice',
          phase: 'phase_2',
          prompt: 'In a Seaborn correlation heatmap grid, what value indicates the strongest negative relationship?',
          options: [
            '-1.00',
            '0.00',
            '1.00',
            '-0.05'
          ],
          answer: '-1.00',
          successExplanation: 'Correlation coefficients scale from -1.0 to 1.0. A value of -1.0 represents a perfect inverse linear relationship.',
          failureTip: 'Negative correlations are below zero, with larger absolute values showing stronger trends.',
        ),
      if (widget.nodeId == 'node_6.1')
        LessonQuestion(
          id: 'node_6.1_q1',
          type: 'keypad',
          phase: 'phase_2',
          prompt: 'Cohort analysis calculations: If Cohort Month 1 had 500 sign-ups, and Month 2 retained 125, what is the retention rate (%)?',
          options: [],
          answer: 25,
          successExplanation: 'Retention Rate = (Retained Users / Initial Users) * 100. Thus, (125 / 500) * 100 = 25%.',
          failureTip: 'Divide month 2 count by initial count and convert to percentage.',
        ),
      if (widget.nodeId == 'node_7.1')
        LessonQuestion(
          id: 'node_7.1_q1',
          type: 'slider_math',
          phase: 'phase_2',
          prompt: 'Adjust the slope slider (beta_1) to minimize the Mean Squared Error (MSE) for our linear regression line (target value: 0.35):',
          options: [],
          answer: 0.35,
          successExplanation: 'Awesome! Setting the slope coefficient beta_1 to 0.35 minimizes the distance of all points to the regression line, yielding minimum MSE.',
          failureTip: 'Slide the coefficient to align with 0.35.',
        ),
      if (widget.nodeId == 'node_8.1')
        LessonQuestion(
          id: 'node_8.1_q1',
          type: 'syntax_scramble',
          phase: 'phase_3',
          prompt: 'Reconstruct the DAX calculated field for Sales Growth compared to all calendar years:',
          options: ['Sales_Growth = ', 'CALCULATE(', 'SUM(Sales[Amount]),', ' ALL(Calendar[Year]))'],
          answer: ['Sales_Growth = ', 'CALCULATE(', 'SUM(Sales[Amount]),', ' ALL(Calendar[Year]))'],
          successExplanation: 'CALCULATE shifts context filters, and ALL ignores specific date constraints to aggregate totals.',
          failureTip: 'Formula: Growth = CALCULATE( SUM(), ALL() )',
        ),
      if (widget.nodeId == 'node_9.1')
        LessonQuestion(
          id: 'node_9.1_q1',
          type: 'multiple_choice',
          phase: 'phase_3',
          prompt: 'Retention has dropped by 15%. What is your initial investigative sequence?',
          options: [
            'Define metrics -> Segment retention -> Check telemetry pipes -> Propose changes',
            'Propose promotional discount -> Deploy new features -> Run SQL query -> Write report',
            'Call the marketing agency -> Ask the CEO -> Check company revenue -> Reset databases',
            'Delete old cohorts -> Clean Python logs -> Merge Tableau charts'
          ],
          answer: 'Define metrics -> Segment retention -> Check telemetry pipes -> Propose changes',
          successExplanation: 'First define constraints, segment patterns by device/cohort to isolate the bottleneck, check tracking logs, and then propose adjustments.',
          failureTip: 'Diagnostic flow starts with definition and segmentation before recommendations.',
        ),
    ];

    if (_questions.isEmpty) {
      _questions = [
        LessonQuestion(
          id: 'practice_q1',
          type: 'multiple_choice',
          phase: 'practice',
          prompt: 'Which SQL keyword is used to filter query aggregates?',
          options: ['HAVING', 'WHERE', 'ORDER BY', 'GROUP BY'],
          answer: 'HAVING',
          successExplanation: 'HAVING filters groups created by GROUP BY, whereas WHERE filters individual data rows.',
          failureTip: 'WHERE handles raw rows; grouped summary aggregations are filtered differently.',
        ),
      ];
    }
  }

  void _checkAnswer() {
    final question = _questions[_currentQuestionIndex];
    bool correct = false;

    if (question.type == 'multiple_choice' || question.type == 'visual_match') {
      correct = _selectedMcOption == question.answer;
    } else if (question.type == 'syntax_scramble') {
      final answerList = question.answer as List<String>;
      if (_scrambledSelection.length == answerList.length) {
        correct = true;
        for (int i = 0; i < answerList.length; i++) {
          if (_scrambledSelection[i] != answerList[i]) {
            correct = false;
            break;
          }
        }
      }
    } else if (question.type == 'keypad') {
      final inputVal = int.tryParse(_keypadController.text);
      correct = inputVal == question.answer;
    } else if (question.type == 'slider_math') {
      correct = (_sliderValue - (question.answer as double)).abs() < 0.05;
    }

    setState(() {
      _isCorrect = correct;
      _isAnswerChecked = true;
      if (!correct) {
        _hasFailedCurrentQuestion = true;
      }
    });
  }

  void _retryQuestion() {
    setState(() {
      _isAnswerChecked = false;
      _selectedMcOption = null;
      _scrambledSelection = [];
      _keypadController.clear();
      _sliderValue = 0.5;
    });
  }

  void _nextQuestion() async {
    final question = _questions[_currentQuestionIndex];
    final user = ref.read(userProfileProvider);
    if (user == null) return;

    final durationMs = DateTime.now().difference(_startTime).inMilliseconds;

    // Log Telemetry Event to local SQLite database
    await TelemetryService.logEvent(
      eventType: 'lesson_action',
      unitId: user.currentUnit,
      nodeId: widget.nodeId,
      phase: question.phase,
      interactionMode: question.type,
      durationMs: durationMs,
      isCorrect: _isCorrect,
      activeStreak: user.streak,
      remainingHearts: user.hearts,
    );

    // Only award XP and Coins if they got it right on the first attempt
    if (_isCorrect && !_hasFailedCurrentQuestion) {
      int speedBonus = durationMs < 10000 ? 5 : 0;
      await ref.read(userProfileProvider.notifier).addXp(10 + speedBonus, onLevelUp: (newLvl) {});
      await ref.read(userProfileProvider.notifier).addCoins(15);
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswerChecked = false;
        _selectedMcOption = null;
        _scrambledSelection = [];
        _keypadController.clear();
        _sliderValue = 0.5;
        _hasFailedCurrentQuestion = false;
        _startTime = DateTime.now();
      });
    } else {
      if (_isCorrect && widget.nodeId.startsWith('node_')) {
        await ref.read(userProfileProvider.notifier).incrementUnit();
        await ref.read(userProfileProvider.notifier).updateStreaks('coding');
      }
      _showFinishedDialog();
    }
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('LESSON COMPLETE!', style: TextStyle(color: RpgColors.primary, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Excellent work! You completed this lesson node.', style: TextStyle(color: RpgColors.textPrimary)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: RpgColors.primary,
              side: BorderSide(color: Color(0xff46a302), width: 2),
            ),
            child: Text('CONTINUE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    if (user == null) return SizedBox();

    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Persistent status bar (sticky head)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: RpgColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  
                  // Progress indicator
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: Color(0xffe5e5e5),
                        color: RpgColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  
                  // Streak
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, color: RpgColors.accent, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '${user.streak}', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: RpgColors.accent),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),

                  // Hearts
                  Row(
                    children: [
                      Icon(Icons.favorite, color: RpgColors.error, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '${user.hearts}', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: RpgColors.error),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: RpgColors.border, height: 2),

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.nodeTitle.toUpperCase(),
                      style: TextStyle(color: RpgColors.secondary, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
                    ),
                    SizedBox(height: 12),
                    
                    Text(
                      question.prompt,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: RpgColors.textPrimary),
                    ),
                    SizedBox(height: 24),

                    // Render layouts
                    if (question.type == 'multiple_choice')
                      _buildMcLayout(question)
                    else if (question.type == 'visual_match')
                      _buildVisualMatchLayout(question)
                    else if (question.type == 'syntax_scramble')
                      _buildScrambleLayout(question)
                    else if (question.type == 'keypad')
                      _buildKeypadLayout(question)
                    else if (question.type == 'slider_math')
                      _buildSliderLayout(question),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Drawer (Verification Drawer)
            _buildVerifyDrawer(question),
          ],
        ),
      ),
    );
  }

  Widget _buildMcLayout(LessonQuestion question) {
    return Column(
      children: question.options.map((opt) {
        final bool isSelected = _selectedMcOption == opt;
        
        final Color cardFill = isSelected ? RpgColors.activeCard : Colors.white;
        final Color borderColor = isSelected ? RpgColors.secondary : RpgColors.border;
        final Color bottomShadowColor = isSelected ? Color(0xff1899d6) : Color(0xffdcdcdc);

        return Container(
          margin: EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: cardFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: bottomShadowColor,
                offset: const Offset(0, 3),
                blurRadius: 0,
              )
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isAnswerChecked
                ? null
                : () {
                    setState(() {
                      _selectedMcOption = opt;
                    });
                  },
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? RpgColors.secondary : RpgColors.textSecondary,
                        width: 2.5,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: CircleAvatar(radius: 6, backgroundColor: RpgColors.secondary),
                          )
                        : null,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 14,
                        color: RpgColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVisualMatchLayout(LessonQuestion question) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final opt = question.options[index];
        final bool isSelected = _selectedMcOption == opt;

        final Color cardFill = isSelected ? RpgColors.activeCard : Colors.white;
        final Color borderColor = isSelected ? RpgColors.secondary : RpgColors.border;
        final Color bottomShadowColor = isSelected ? Color(0xff1899d6) : Color(0xffdcdcdc);

        return Container(
          decoration: BoxDecoration(
            color: cardFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: bottomShadowColor,
                offset: const Offset(0, 3),
                blurRadius: 0,
              )
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isAnswerChecked
                ? null
                : () {
                    setState(() {
                      _selectedMcOption = opt;
                    });
                  },
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xfff7f7f7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomPaint(
                        painter: DistributionChartPainter(index: index),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    opt,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: RpgColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrambleLayout(LessonQuestion question) {
    final remainingOptions = question.options.where((opt) => !_scrambledSelection.contains(opt)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grid Slots for assembled code
        Container(
          constraints: const BoxConstraints(minHeight: 90),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xfff7f7f7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RpgColors.border, width: 2),
          ),
          child: _scrambledSelection.isEmpty
              ? Center(
                  child: Text(
                    'TAP CHIPS TO RECONSTRUCT CODE', 
                    style: TextStyle(color: RpgColors.textSecondary, fontSize: 11, letterSpacing: 0.5, fontWeight: FontWeight.bold),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _scrambledSelection.map((opt) {
                    return ActionChip(
                      backgroundColor: RpgColors.activeCard,
                      side: BorderSide(color: RpgColors.secondary, width: 1.5),
                      label: Text(
                        opt,
                        style: GoogleFonts.jetBrainsMono(color: RpgColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isAnswerChecked
                          ? null
                          : () {
                              setState(() {
                                _scrambledSelection.remove(opt);
                              });
                            },
                    );
                  }).toList(),
                ),
        ),
        SizedBox(height: 24),

        // Available Pool Chips
        Text(
          'AVAILABLE BLOCKS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: RpgColors.textSecondary, letterSpacing: 0.5),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: remainingOptions.map((opt) {
            return ActionChip(
              backgroundColor: Colors.white,
              side: BorderSide(color: RpgColors.border, width: 1.5),
              label: Text(
                opt,
                style: GoogleFonts.jetBrainsMono(color: RpgColors.textPrimary, fontSize: 12),
              ),
              onPressed: _isAnswerChecked
                  ? null
                  : () {
                      setState(() {
                        _scrambledSelection.add(opt);
                      });
                    },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildKeypadLayout(LessonQuestion question) {
    return Column(
      children: [
        TextField(
          controller: _keypadController,
          keyboardType: TextInputType.number,
          enabled: !_isAnswerChecked,
          style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.bold, color: RpgColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'ENTER RESULT VALUE',
            hintText: 'e.g., 25',
          ),
        ),
      ],
    );
  }

  Widget _buildSliderLayout(LessonQuestion question) {
    return Column(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Color(0xfff7f7f7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RpgColors.border, width: 2),
          ),
          child: CustomPaint(
            painter: RegressionLinePainter(slope: _sliderValue),
            size: Size.infinite,
          ),
        ),
        SizedBox(height: 16),
        
        Text(
          'Slope Coefficient (beta_1): ${_sliderValue.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold, color: RpgColors.textPrimary, fontSize: 14),
        ),
        Slider(
          value: _sliderValue,
          min: 0.0,
          max: 1.0,
          activeColor: RpgColors.primary,
          inactiveColor: RpgColors.border,
          onChanged: _isAnswerChecked
              ? null
              : (val) {
                  setState(() {
                    _sliderValue = val;
                  });
                },
        ),
      ],
    );
  }

  Widget _buildVerifyDrawer(LessonQuestion question) {
    if (_isAnswerChecked) {
      final Color drawerColor = _isCorrect ? RpgColors.primary : RpgColors.error;
      final Color drawerBg = _isCorrect ? Color(0xffd7ffb8) : Color(0xffffdfe0);
      final Color textColor = _isCorrect ? Color(0xff3e7a00) : Color(0xffb01c1c);

      return Container(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: drawerBg,
          border: Border(top: BorderSide(color: drawerColor, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(_isCorrect ? Icons.check_circle : Icons.error, color: drawerColor, size: 28),
                SizedBox(width: 8),
                Text(
                  _isCorrect ? 'EXCELLENT JOB!' : 'INCORRECT',
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              _isCorrect ? question.successExplanation : question.failureTip,
              style: TextStyle(fontSize: 13, color: textColor, height: 1.4),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isCorrect ? _nextQuestion : _retryQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: drawerColor, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: _isCorrect ? Color(0xff46a302) : Color(0xffb01c1c), width: 2),
                ),
              ),
              child: Text(_isCorrect ? 'CONTINUE' : 'TRY AGAIN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final bool isInteractable = _selectedMcOption != null ||
        _scrambledSelection.isNotEmpty ||
        _keypadController.text.isNotEmpty ||
        question.type == 'slider_math';

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: RpgColors.border, width: 2)),
      ),
      child: ElevatedButton(
        onPressed: isInteractable ? _checkAnswer : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isInteractable ? RpgColors.primary : Color(0xffe5e5e5),
          foregroundColor: isInteractable ? Colors.white : RpgColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isInteractable ? Color(0xff46a302) : Color(0xffd8d8d8), 
              width: 2,
            ),
          ),
        ),
        child: Text('CHECK ANSWER', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// Painters for visual options
class DistributionChartPainter extends CustomPainter {
  final int index;
  DistributionChartPainter({required this.index});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RpgColors.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (index == 0) {
      // Right skewed tail
      path.moveTo(10, size.height - 15);
      path.quadraticBezierTo(size.width * 0.25, 15, size.width * 0.35, 35);
      path.quadraticBezierTo(size.width * 0.6, size.height - 15, size.width - 10, size.height - 15);
    } else if (index == 1) {
      // Left skewed tail
      path.moveTo(10, size.height - 15);
      path.quadraticBezierTo(size.width * 0.4, size.height - 15, size.width * 0.65, 35);
      path.quadraticBezierTo(size.width * 0.75, 15, size.width - 10, size.height - 15);
    } else {
      // Symmetric normal distribution bell curve
      path.moveTo(10, size.height - 15);
      path.quadraticBezierTo(size.width * 0.2, size.height - 15, size.width * 0.5, 25);
      path.quadraticBezierTo(size.width * 0.8, size.height - 15, size.width - 10, size.height - 15);
    }

    canvas.drawPath(path, paint);

    final linePaint = Paint()
      ..color = RpgColors.border
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(10, size.height - 15), Offset(size.width - 10, size.height - 15), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RegressionLinePainter extends CustomPainter {
  final double slope;
  RegressionLinePainter({required this.slope});

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = RpgColors.secondary
      ..style = PaintingStyle.fill;

    final points = [
      const Offset(40, 140),
      const Offset(80, 110),
      const Offset(120, 100),
      const Offset(160, 70),
      const Offset(200, 60),
    ];

    for (var pt in points) {
      canvas.drawCircle(pt, 5, pointPaint);
    }

    final gridPaint = Paint()..color = RpgColors.border;
    canvas.drawLine(Offset(20, size.height - 20), Offset(size.width - 20, size.height - 20), gridPaint);
    canvas.drawLine(Offset(20, 20), Offset(20, size.height - 20), gridPaint);

    final linePaint = Paint()
      ..color = RpgColors.primary
      ..strokeWidth = 3;

    double startY = size.height - 20 - (slope * (size.height - 40));
    double endY = size.height - 20 - (slope * 2.5 * (size.height - 40));
    
    endY = endY.clamp(20.0, size.height - 20);

    canvas.drawLine(
      Offset(20, startY),
      Offset(size.width - 20, endY),
      linePaint,
    );

    double targetSlope = 0.35;
    double mse = pow(slope - targetSlope, 2) * 100;

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'MSE (Error): ${mse.toStringAsFixed(2)}',
        style: TextStyle(color: RpgColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, const Offset(30, 30));
  }

  @override
  bool shouldRepaint(covariant RegressionLinePainter oldDelegate) => oldDelegate.slope != slope;
}
