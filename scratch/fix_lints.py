import os

files = [
    'lib/data/services/firebase_service.dart',
    'lib/data/services/mongo_sync_service.dart',
    'lib/data/services/telemetry_service.dart'
]

for f in files:
    with open(f, encoding='utf-8') as file:
        content = file.read()
    if 'package:flutter/foundation.dart' not in content:
        content = "import 'package:flutter/foundation.dart';\n" + content
    content = content.replace('print(', 'debugPrint(')
    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)
