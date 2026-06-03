"""
fix_mojibake.py - Fix Windows-1252 → UTF-8 Mojibake trong Dart files.
Đọc file dưới dạng bytes, decode Latin-1, re-encode UTF-8.
"""
import sys
import os
import shutil
import io
from pathlib import Path

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

def fix_file(path: Path, dry_run: bool = False) -> bool:
    """Trả về True nếu file được sửa."""
    raw = path.read_bytes()
    
    # Thử decode UTF-8 trước — nếu thành công thì file không bị lỗi
    try:
        raw.decode('utf-8')
        return False  # File đã đúng UTF-8, bỏ qua
    except UnicodeDecodeError:
        pass
    
    # Decode Latin-1 (Windows-1252) rồi re-encode UTF-8
    try:
        text = raw.decode('latin-1')
        fixed = text.encode('utf-8')
        if not dry_run:
            # Backup
            shutil.copy2(path, str(path) + '.bak')
            path.write_bytes(fixed)
        return True
    except Exception as e:
        print(f"[ERROR] {path}: {e}")
        return False


def main():
    dry_run = '--dry-run' in sys.argv
    target_dir = Path(sys.argv[1]) if len(sys.argv) > 1 and not sys.argv[1].startswith('--') else Path('apps/mobile/lib')
    
    print(f"Scanning: {target_dir.resolve()}")
    print(f"Dry run: {dry_run}")
    print()
    
    fixed = []
    skipped = []
    
    for dart_file in target_dir.rglob('*.dart'):
        result = fix_file(dart_file, dry_run)
        if result:
            fixed.append(dart_file)
            print(f"  [FIXED] {dart_file.name}")
        else:
            skipped.append(dart_file)
    
    print(f"\nFixed: {len(fixed)} files")
    print(f"Already OK: {len(skipped)} files")
    if fixed and not dry_run:
        print("Backup files saved as *.bak")

if __name__ == '__main__':
    main()
