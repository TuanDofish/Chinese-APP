import pdfplumber
import json
import os
import re

def clean_text(text):
    if not text:
        return ""
    # Remove internal line breaks and multiple spaces
    text = re.sub(r'\s+', ' ', text).strip()
    return text

def parse_pdf(file_path):
    print(f"Parsing tables from {file_path}...")
    results = []
    
    with pdfplumber.open(file_path) as pdf:
        # Some PDFs don't have perfect table lines, so we use string-based heuristic 
        # but let's first try extract_tables()
        for page_num, page in enumerate(pdf.pages):
            tables = page.extract_tables()
            for table in tables:
                for row in table:
                    # Expecting columns roughly like STT, Grammar Point, Explanation, Example
                    cleaned_row = [clean_text(cell) for cell in row]
                    # Filter out empty rows or header rows
                    if len(cleaned_row) >= 3 and cleaned_row[0] != 'STT' and cleaned_row[1] != 'Điểm ngữ pháp':
                        # Try to merge columns if it's over 4, or just store the raw array
                        results.append(cleaned_row)
                        
    out_name = file_path.replace('.pdf', '_tables.json')
    with open(out_name, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    print(f"Saved {len(results)} rows to {out_name}")

for file in os.listdir('.'):
    if file.endswith('.pdf'):
        parse_pdf(file)
