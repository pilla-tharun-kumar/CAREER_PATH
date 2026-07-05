import re

def parse_html(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')
    
    curriculum = []
    current_unit = None
    unit_idx = 1
    node_idx = 1
    
    for line in lines:
        if '<div class="week-card' in line:
            if current_unit:
                curriculum.append(current_unit)
            current_unit = {
                "unitNumber": unit_idx,
                "name": "",
                "description": "",
                "category": "setup",
                "nodes": []
            }
            unit_idx += 1
            node_idx = 1
            
        if current_unit is not None:
            if '<span class="week-label">' in line:
                m = re.search(r'<span class="week-label">(.*?)</span>', line)
                if m: current_unit['name'] = m.group(1).strip()
            if '<span class="week-title">' in line:
                m = re.search(r'<span class="week-title">(.*?)</span>', line)
                if m: current_unit['name'] += ": " + m.group(1).strip()
                
            if '<div class="task-item"' in line:
                text_match = re.search(r'<div class="task-text">(.*?)</div>', line)
                link_match = re.search(r'<a href="(.*?)"', line)
                
                title = "Task"
                desc = ""
                url = ""
                if text_match:
                    raw_text = text_match.group(1)
                    # Example: <strong>Create an IndiaBIX account</strong> — free aptitude...
                    strong_match = re.search(r'<strong>(.*?)</strong>', raw_text)
                    if strong_match:
                        title = strong_match.group(1).strip()
                        desc = raw_text.replace(f"<strong>{title}</strong>", "").strip()
                        if desc.startswith("—") or desc.startswith("-"):
                            desc = desc[1:].strip()
                    else:
                        title = raw_text.split('—')[0].strip() if '—' in raw_text else raw_text
                        desc = raw_text.split('—')[1].strip() if '—' in raw_text else raw_text
                
                if link_match:
                    url = link_match.group(1).strip()
                    
                is_video = 'true' if 'youtu' in url else 'false'
                
                title = title.replace("'", "\\'")
                desc = desc.replace("'", "\\'")
                
                current_unit['nodes'].append(f"""
        PathNode(
          id: 'node_{unit_idx-1}.{node_idx}', 
          title: '{title}', 
          description: '{desc}',
          category: 'setup',
          resource: const StudyResource(title: '{title}', url: '{url}', isVideo: {is_video}),
        ),""")
                node_idx += 1
                
    if current_unit:
        curriculum.append(current_unit)
        
    # Generate dart code
    dart_code = "  static const List<UnitSection> placementCurriculum = [\n"
    for c in curriculum:
        dart_code += f"""    UnitSection(
      unitNumber: {c['unitNumber']},
      name: '{c['name'].replace("'", "\\'")}',
      description: '{c['description']}',
      category: '{c['category']}',
      nodes: ["""
        for n in c['nodes']:
            dart_code += n
        dart_code += """
      ],
    ),
"""
    dart_code += "  ];\n"
    
    with open('c:/Projects/tarun flutter/rpg game/scratch/placement_curriculum.dart', 'w', encoding='utf-8') as f:
        f.write(dart_code)

parse_html('c:/Projects/tarun flutter/rpg game/MCA_Placement_Preparation.html')
