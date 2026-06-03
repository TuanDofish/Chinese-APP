import PyPDF2
import os

for file in os.listdir('.'):
    if file.endswith('.pdf'):
        print(f"Processing {file}...")
        try:
            with open(file, 'rb') as f:
                reader = PyPDF2.PdfReader(f)
                text = ""
                for page in reader.pages:
                    text += page.extract_text() + "\n"
                
                out_name = file.replace('.pdf', '_out.txt')
                with open(out_name, 'w', encoding='utf-8') as out_f:
                    out_f.write(text)
                print(f"Extraction successful: {len(text)} characters to {out_name}")
        except Exception as e:
            print(f"Error reading {file}: {e}")
