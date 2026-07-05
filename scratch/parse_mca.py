import re
from bs4 import BeautifulSoup
import json

def parse_html(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    soup = BeautifulSoup(content, 'html.parser')
    
    phases = soup.find_all('div', class_='phase-block')
    
    curriculum = []
    unit_num = 1
    
    for phase in phases:
        phase_header = phase.find('div', class_='phase-header')
        if not phase_header:
            continue
        
        weeks = phase.find_all('div', class_='week-card')
        for week in weeks:
            title_el = week.find('span', class_='week-title')
            label_el = week.find('span', class_='week-label')
            
            unit_name = label_el.text.strip() if label_el else f"Unit {unit_num}"
            if title_el:
                unit_name += ": " + title_el.text.strip()
            
            nodes = []
            
            tasks = week.find_all('div', class_='task-item')
            for i, task in enumerate(tasks):
                task_text = task.find('div', class_='task-text')
                task_link = task.find('a', class_='task-link')
                
                desc = task_text.text.strip() if task_text else ""
                # remove " — " from description if present
                desc = re.sub(r'^[^\—]+\—\s*', '', desc)
                title = task_text.find('strong').text.strip() if task_text and task_text.find('strong') else f"Task {i+1}"
                
                url = task_link['href'] if task_link else ""
                
                is_video = "youtu" in url
                
                nodes.append({
                    "id": f"node_{unit_num}.{i+1}",
                    "title": title,
                    "description": desc,
                    "category": "setup",  # we can just use a default category
                    "url": url,
                    "isVideo": is_video
                })
                
            if nodes:
                curriculum.append({
                    "unitNumber": unit_num,
                    "name": unit_name,
                    "description": "",
                    "category": "setup",
                    "nodes": nodes
                })
                unit_num += 1

    with open('c:/Projects/tarun flutter/rpg game/scratch/mca_curriculum.json', 'w', encoding='utf-8') as f:
        json.dump(curriculum, f, indent=2)

parse_html('c:/Projects/tarun flutter/rpg game/MCA_Placement_Preparation.html')
