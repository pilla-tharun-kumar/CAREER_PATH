import os

liquid_path = r'c:\Projects\tarun flutter\rpg game\lib\screens\liquid_scroll_tree_screen.dart'
placement_path = r'c:\Projects\tarun flutter\rpg game\scratch\placement_curriculum.dart'
output_path = r'c:\Projects\tarun flutter\rpg game\lib\data\curriculum_data.dart'

with open(liquid_path, 'r', encoding='utf-8') as f:
    liquid_content = f.read()
    
with open(placement_path, 'r', encoding='utf-8') as f:
    placement_content = f.read()

# Extract data analyst curriculum
start_idx = liquid_content.find('  final List<UnitSection> _curriculum = [')
end_idx = liquid_content.find('  ];\n\n  @override\n  void initState() {') + 4

data_analyst_str = liquid_content[start_idx:end_idx].replace('final List<UnitSection> _curriculum =', 'static const List<UnitSection> dataAnalystCurriculum =')

dart_code = f"""import '../screens/liquid_scroll_tree_screen.dart';

class CurriculumData {{
{data_analyst_str}

{placement_content}
}}
"""

with open(output_path, 'w', encoding='utf-8') as f:
    f.write(dart_code)
