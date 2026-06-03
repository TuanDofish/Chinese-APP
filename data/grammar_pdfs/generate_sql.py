import json
import os

levels = ['hsk1', 'hsk2', 'hsk3', 'hsk4', 'hsk5']

sql_statements = []
sql_statements.append("TRUNCATE TABLE grammar RESTART IDENTITY CASCADE;")

for level in levels:
    filename = f"{level}_tables.json"
    if not os.path.exists(filename):
        continue
    
    with open(filename, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    level_str = level.upper().replace('HSK', 'HSK ')
    
    for row in data:
        if len(row) < 3:
            continue
            
        is_4_cols = (len(row) >= 4 and row[0].strip().isdigit())
        
        if is_4_cols:
            title = row[1].replace("'", "''").strip()
            explanation = row[2].replace("'", "''").strip()
            examples = row[3].replace("'", "''").strip()
        else:
            if 'Điểm ngữ pháp' in row[0] or 'STT' in row[0]:
                continue
            title = row[0].replace("'", "''").strip()
            explanation = row[1].replace("'", "''").strip()
            examples = row[2].replace("'", "''").strip()
            
        if not title or not examples:
            continue
            
        sql = f"INSERT INTO grammar (level, title, explanation, examples) VALUES ('{level_str}', '{title}', '{explanation}', '{examples}');"
        sql_statements.append(sql)

out_file = "seed_grammar.sql"
with open(out_file, 'w', encoding='utf-8') as f:
    f.write("\n".join(sql_statements))

print(f"Generated {len(sql_statements)-1} SQL insert statements in {out_file}")
