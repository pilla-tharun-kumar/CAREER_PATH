import os

file_path = r'c:\Projects\tarun flutter\rpg game\lib\screens\liquid_scroll_tree_screen.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update PathNode
old_path_node = '''class PathNode {
  final String id;
  final String title;
  final String description;
  final bool isLock;
  final String category; // 'setup' | 'excel' | 'stats' | 'sql' | 'python' | 'ml' | 'bi' | 'jobs'
  final List<StudyResource> resources;

  PathNode({
    required this.id,
    required this.title,
    required this.description,
    this.isLock = false,
    required this.category,
    required this.resources,
  });
}'''

new_path_node = '''class PathNode {
  final String id;
  final String title;
  final String description;
  final bool isLock;
  final String category; // 'setup' | 'excel' | 'stats' | 'sql' | 'python' | 'ml' | 'bi' | 'jobs'
  final StudyResource resource;

  PathNode({
    required this.id,
    required this.title,
    required this.description,
    this.isLock = false,
    required this.category,
    required this.resource,
  });
}'''

content = content.replace(old_path_node, new_path_node)

# 2. Update Curriculum
import re
curriculum_pattern = re.compile(r'final List<UnitSection> _curriculum = \[.*?\];', re.DOTALL)

new_curriculum = '''final List<UnitSection> _curriculum = [
    UnitSection(
      unitNumber: 1,
      name: 'Day 0: Environmental Setup',
      description: 'Create your developer accounts and download data tools.',
      category: 'setup',
      nodes: [
        PathNode(
          id: 'node_0.1', 
          title: 'GitHub Pack', 
          description: 'Establish profiles on GitHub and Kaggle.',
          category: 'setup',
          resource: const StudyResource(title: 'GitHub Developer Pack', url: 'https://education.github.com/pack', isVideo: false),
        ),
        PathNode(
          id: 'node_0.2', 
          title: 'Mode SQL Sandbox', 
          description: 'Interactive SQL Practice.',
          category: 'setup',
          resource: const StudyResource(title: 'Mode SQL Practice Sandbox', url: 'https://mode.com/sql-tutorial/', isVideo: false),
        ),
      ],
    ),
    UnitSection(
      unitNumber: 2,
      name: 'Excel Core Operations',
      description: 'Master VLOOKUP, INDEX-MATCH, and Pivot Table operations.',
      category: 'excel',
      nodes: [
        PathNode(
          id: 'node_1.1', 
          title: 'Lookup Duets', 
          description: 'VLOOKUP vs INDEX-MATCH Guide.',
          category: 'excel',
          resource: const StudyResource(title: 'VLOOKUP vs INDEX-MATCH', url: 'https://www.youtube.com/watch?v=d3BYVQ6xIE4', isVideo: true),
        ),
        PathNode(
          id: 'node_1.2', 
          title: 'Conditional Math', 
          description: 'SUMIF, COUNTIF, and text formulas.',
          category: 'excel',
          resource: const StudyResource(title: 'Microsoft SUMIF Docs', url: 'https://support.microsoft.com/en-us/office/sumif-function-169b8c99-c05c-4483-a712-1697a653039b', isVideo: false),
        ),
      ],
    ),
    UnitSection(
      unitNumber: 3,
      name: 'Advanced Excel & Cleaning',
      description: 'Power Query pipelines and messy data cleaning.',
      category: 'excel',
      nodes: [
        PathNode(
          id: 'node_1.3', 
          title: 'Power Query', 
          description: 'Chandoo Power Query Tutorial.',
          category: 'excel',
          resource: const StudyResource(title: 'Power Query Tutorial', url: 'https://www.youtube.com/watch?v=0aeZX1l4JT4', isVideo: true),
        ),
        PathNode(
          id: 'node_1.4', 
          title: 'Messy Data', 
          description: 'YouTube stats dataset cleaning.',
          category: 'excel',
          resource: const StudyResource(title: 'messy YouTube stats', url: 'https://www.kaggle.com/datasets/datasnaek/youtube-new', isVideo: false),
        ),
      ],
    ),
    UnitSection(
      unitNumber: 4,
      name: 'Business Statistics',
      description: 'Mean, variance, standard deviation, and distributions.',
      category: 'stats',
      nodes: [
        PathNode(
          id: 'node_2.1', 
          title: 'Statistics Prob.', 
          description: 'Khan Academy Statistics.',
          category: 'stats',
          resource: const StudyResource(title: 'Khan Academy Stats', url: 'https://www.khanacademy.org/math/statistics-probability', isVideo: false),
        ),
        PathNode(
          id: 'node_2.2', 
          title: 'Correlation', 
          description: 'Correlation vs Causation.',
          category: 'stats',
          resource: const StudyResource(title: 'Correlation vs Causation', url: 'https://www.youtube.com/watch?v=GtV-VYdNt_g', isVideo: true),
        ),
        PathNode(
          id: 'node_2.3', 
          title: 'p-values', 
          description: 'Recognize p-value triggers.',
          category: 'stats',
          resource: const StudyResource(title: 'StatQuest: p-values', url: 'https://www.youtube.com/watch?v=5Z9OIYA8He8', isVideo: true),
        ),
      ],
    ),
    UnitSection(
      unitNumber: 5,
      name: 'SQL Query Foundations',
      description: 'Filter rows, merge tables, and join datasets.',
      category: 'sql',
      nodes: [
        PathNode(
          id: 'node_3.1', 
          title: 'SQLZoo', 
          description: 'Interactive query sandbox.',
          category: 'sql',
          resource: const StudyResource(title: 'SQLZoo sandbox', url: 'https://sqlzoo.net/wiki/SQL_Tutorial', isVideo: false),
        ),
        PathNode(
          id: 'node_3.2', 
          title: 'SQL Tutorial', 
          description: 'Hamedani SQL Tutorial.',
          category: 'sql',
          resource: const StudyResource(title: 'Hamedani SQL', url: 'https://www.youtube.com/watch?v=7S_tz1z_5bA', isVideo: true),
        ),
        PathNode(
          id: 'node_3.3', 
          title: 'Visual JOINs', 
          description: 'INNER, LEFT, and FULL table merges.',
          category: 'sql',
          resource: const StudyResource(title: 'Visual SQL JOINs', url: 'https://www.youtube.com/watch?v=9yeOJ0ZMUYw', isVideo: true),
        ),
      ],
    ),
    UnitSection(
      unitNumber: 6,
      name: 'Advanced SQL Querying',
      description: 'CTEs, window functions, and rank ordering.',
      category: 'sql',
      nodes: [
        PathNode(
          id: 'node_3.4', 
          title: 'Window Functions', 
          description: 'Row partitions and data ranks.',
          category: 'sql',
          resource: const StudyResource(title: 'Mode SQL Window func', url: 'https://mode.com/sql-tutorial/sql-window-functions/', isVideo: false),
        ),
        PathNode(
          id: 'node_3.5', 
          title: 'DataLemur', 
          description: 'DataLemur SQL Practice Platform.',
          category: 'sql',
          resource: const StudyResource(title: 'DataLemur', url: 'https://datalemur.com/', isVideo: false),
        ),
      ],
    ),
    UnitSection(
      unitNumber: 7,
      name: 'Python Foundations',
      description: 'Core coding syntax, dict lookups, and Jupyter.',
      category: 'python',
      nodes: [
        PathNode(
          id: 'node_4.1', 
          title: 'Python Kaggle', 
          description: 'Kaggle Intro to Python.',
          category: 'python',
          resource: const StudyResource(title: 'Kaggle Python', url: 'https://www.kaggle.com/learn/python', isVideo: false),
        ),
        PathNode(
          id: 'node_4.2', 
          title: 'CS50 Python', 
          description: 'Harvard CS50 Python lectures.',
          category: 'python',
          resource: const StudyResource(title: 'Harvard CS50', url: 'https://cs50.harvard.edu/python/', isVideo: false),
        ),
      ],
    ),
    UnitSection(
      unitNumber: 8,
      name: 'Python Wrangling & Pandas',
      description: 'Pandas DataFrames, merge queries, and plotting.',
      category: 'python',
      nodes: [
        PathNode(
          id: 'node_4.3', 
          title: 'Pandas Kaggle', 
          description: 'Kaggle Pandas data cleaning.',
          category: 'python',
          resource: const StudyResource(title: 'Kaggle Pandas', url: 'https://www.kaggle.com/learn/pandas', isVideo: false),
        ),
        PathNode(
          id: 'node_4.4', 
          title: 'Seaborn guides', 
          description: 'Seaborn data visualization.',
          category: 'python',
          resource: const StudyResource(title: 'Seaborn viz', url: 'https://seaborn.pydata.org/tutorial.html', isVideo: false),
        ),
      ],
    ),
    UnitSection(
      unitNumber: 9,
      name: 'Machine Learning Basics',
      description: 'Linear Regression modeling and clustering.',
      category: 'ml',
      nodes: [
        PathNode(
          id: 'node_7.1', 
          title: 'StatQuest LinReg', 
          description: 'StatQuest: Linear Regression.',
          category: 'ml',
          resource: const StudyResource(title: 'StatQuest LinReg', url: 'https://www.youtube.com/watch?v=PaFPbb66DxQ', isVideo: true),
        ),
        PathNode(
          id: 'node_7.2', 
          title: 'Intro ML', 
          description: 'Kaggle Intro to Machine Learning.',
          category: 'ml',
          resource: const StudyResource(title: 'Kaggle Intro ML', url: 'https://www.kaggle.com/learn/intro-to-machine-learning', isVideo: false),
        ),
      ],
    ),
    UnitSection(
      unitNumber: 10,
      name: 'BI with Tableau',
      description: 'Workbook visualizations, dimensions, and dashboards.',
      category: 'bi',
      nodes: [
        PathNode(
          id: 'node_8.1', 
          title: 'Tableau Crash', 
          description: 'Traversy Tableau crash course.',
          category: 'bi',
          resource: const StudyResource(title: 'Tableau Crash Course', url: 'https://www.youtube.com/watch?v=TPMlZxRRaBQ', isVideo: true),
        ),
        PathNode(
          id: 'node_8.2', 
          title: 'Tableau Portal', 
          description: 'Tableau official training portal.',
          category: 'bi',
          resource: const StudyResource(title: 'Tableau Training', url: 'https://www.tableau.com/learn/training/20224', isVideo: false),
        ),
      ],
    ),
    UnitSection(
      unitNumber: 11,
      name: 'BI with Power BI',
      description: 'Calculated DAX expressions and Microsoft PL-300.',
      category: 'bi',
      nodes: [
        PathNode(
          id: 'node_8.3', 
          title: 'Guy in a Cube', 
          description: 'Guy in a Cube Power BI Tips.',
          category: 'bi',
          resource: const StudyResource(title: 'Guy in a Cube', url: 'https://www.youtube.com/c/GuyinaCube', isVideo: true),
        ),
        PathNode(
          id: 'node_8.4', 
          title: 'PL-300 Path', 
          description: 'PL-300 certification study path.',
          category: 'bi',
          resource: const StudyResource(title: 'PL-300 Path', url: 'https://learn.microsoft.com/en-us/training/paths/prepare-for-power-bi-analyst-exam/', isVideo: false),
        ),
      ],
    ),
    UnitSection(
      unitNumber: 12,
      name: 'Job Prep & Portfolio Sprint',
      description: 'Resume keywords, mock interviews, and final apps.',
      category: 'jobs',
      nodes: [
        PathNode(
          id: 'node_9.1', 
          title: 'Pramp Mock', 
          description: 'Pramp peer-to-peer mock interviews.',
          category: 'jobs',
          resource: const StudyResource(title: 'Pramp', url: 'https://www.pramp.com/', isVideo: false),
        ),
        PathNode(
          id: 'node_9.2', 
          title: 'Jobscan ATS', 
          description: 'Jobscan ATS Resume scanner checker.',
          category: 'jobs',
          resource: const StudyResource(title: 'Jobscan', url: 'https://www.jobscan.co/', isVideo: false),
        ),
      ],
    ),
  ];'''

content = curriculum_pattern.sub(new_curriculum, content)

# 3. Update _showNodePopup
old_popup = '''  void _showNodePopup(PathNode node, bool isCompleted) {
    final Color categoryColor = _getCategoryColor(node.category);
    final Color bottomBorderColor = _getCategoryBottomColor(node.category);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: RpgColors.primary, size: 18),
                        SizedBox(width: 4),
                        Text('COMPLETED', style: TextStyle(color: RpgColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                node.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: RpgColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                node.description,
                style: const TextStyle(color: RpgColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Interactive study materials
              if (node.resources.isNotEmpty) ...[
                const Text(
                  'STUDY MATERIALS (VIDEOS & GUIDES)',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: RpgColors.textSecondary, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: node.resources.length,
                    itemBuilder: (context, idx) {
                      final res = node.resources[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xfff7f7f7),
                          border: Border.all(color: RpgColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          leading: Icon(
                            res.isVideo ? Icons.play_circle : Icons.description,
                            color: categoryColor,
                          ),
                          title: Text(
                            res.title,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: RpgColors.textPrimary),
                          ),
                          trailing: const Icon(Icons.open_in_new, size: 14, color: RpgColors.textSecondary),
                          onTap: () {
                            Navigator.pop(context);
                            _launchResource(res.url);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startLesson(node);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: categoryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: bottomBorderColor, width: 2),
                  ),
                ),
                child: Text(
                  isCompleted ? 'PRACTICE (+10 XP)' : 'START LESSON',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }'''

new_popup = '''  void _showNodePopup(PathNode node, bool isCompleted) {
    final Color categoryColor = _getCategoryColor(node.category);
    final Color bottomBorderColor = _getCategoryBottomColor(node.category);

    showModalBottomSheet(
      context: context,
      backgroundColor: RpgColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: RpgColors.primary, size: 18),
                        SizedBox(width: 4),
                        Text('COMPLETED', style: TextStyle(color: RpgColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                node.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: RpgColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                node.description,
                style: const TextStyle(color: RpgColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _launchResource(node.resource.url);
                },
                icon: Icon(node.resource.isVideo ? Icons.play_circle : Icons.description, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: categoryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: bottomBorderColor, width: 2),
                  ),
                ),
                label: Text(
                  isCompleted ? 'REVIEW STUDY MATERIAL' : 'START STUDYING',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }'''

content = content.replace(old_popup, new_popup)

# 4. Remove Hearts Pool in banner
old_hearts = '''            const SizedBox(width: 16),

            // Hearts Pool
            Row(
              children: [
                const Icon(Icons.favorite, color: RpgColors.error, size: 22),
                const SizedBox(width: 2),
                Text(
                  '${user.hearts}', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: RpgColors.error),
                ),
              ],
            ),'''
            
content = content.replace(old_hearts, '')

# 5. Fix withOpacity -> withValues in banner
content = content.replace('color: RpgColors.primary.withOpacity(0.1)', 'color: RpgColors.primary.withValues(alpha: 0.1)')

# 6. Fix Colors.white node background to RpgColors.cardBg
content = content.replace('color: isCompleted ? nodeColor : Colors.white', 'color: isCompleted ? nodeColor : RpgColors.cardBg')
# Also fix bottom border of card container to RpgColors.border -> RpgColors.border
# Also fix container color
content = content.replace('backgroundColor: Colors.white,', 'backgroundColor: RpgColors.cardBg,')
content = content.replace('color: Colors.white,', 'color: RpgColors.cardBg,')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated successfully")
