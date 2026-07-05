import os
import re

directories = [
    r'c:\Projects\tarun flutter\rpg game\lib\screens',
    r'c:\Projects\tarun flutter\rpg game\lib\widgets',
]

for d in directories:
    if not os.path.exists(d): continue
    for root, dirs, files in os.walk(d):
        for f in files:
            if f.endswith('.dart'):
                filepath = os.path.join(root, f)
                with open(filepath, 'r', encoding='utf-8') as file:
                    content = file.read()
                
                # We want to remove "const " when used for widgets. 
                # We'll specifically target common widgets.
                widgets = [
                    'Text', 'Icon', 'TextStyle', 'BoxDecoration', 'Container', 'Padding', 'Center', 
                    'Row', 'Column', 'Align', 'Positioned', 'Expanded', 'Flexible', 'SizedBox', 
                    'EdgeInsets', 'Border', 'BorderSide', 'RoundedRectangleBorder', 'LinearGradient',
                    'RadialGradient', 'Scaffold', 'AppBar', 'ListTile', 'CircleAvatar', 'ClipRRect',
                    'ElevatedButton', 'ElevatedButton.styleFrom', 'LinearProgressIndicator', 'Color'
                ]
                
                for w in widgets:
                    # Match 'const WidgetName'
                    pattern = r'const\s+' + w + r'\b'
                    content = re.sub(pattern, w, content)

                with open(filepath, 'w', encoding='utf-8') as file:
                    file.write(content)

print("Const stripped.")
