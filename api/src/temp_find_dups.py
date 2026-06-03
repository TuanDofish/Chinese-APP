import sys
import re

with open(r'd:\Đồ án\app\Chinese app\api\src\dict_seed.sql', 'r', encoding='utf-8') as f:
    text = f.read()

words = re.findall(r"\('([^']+)','([^']+)'", text)
seen = set()
dups = set()
for w, _ in words:
    if w in seen:
        dups.add(w)
    seen.add(w)

print("Duplicates:", dups)

from collections import defaultdict
positions = defaultdict(list)
for idx, line in enumerate(text.split('\n')):
    if line.startswith("('"):
        m = re.match(r"\('([^']+)'", line)
        if m and m.group(1) in dups:
            positions[m.group(1)].append(idx + 1)

for w, pos in dict(positions).items():
    print(f"{w}: lines {pos}")
