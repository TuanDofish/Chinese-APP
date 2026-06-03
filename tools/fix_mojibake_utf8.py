import io
import shutil
import sys
from pathlib import Path

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

MOJIBAKE_MARKERS = (
    'Ã',
    'Â',
    'Ä',
    'Å',
    'Æ',
    'Ç',
    'Ð',
    'Ñ',
    'Ø',
    'Ù',
    'Ú',
    'Û',
    'Ý',
    'Þ',
    'ß',
    'æ',
    'ø',
    'ð',
    'â',
    'ã',
)

CONTROL_REPAIRS = {
    '\u00c4\ufffd': 'Đ',
    '\u00c4\u2018': 'đ',
    '\u00c4\u0192': 'ă',
    '\u00c3\u20ac': 'À',
    '\u00c3\ufffd': 'Á',
}


def _to_original_bytes(content: str) -> bytes:
    raw = bytearray()
    for char in content:
        codepoint = ord(char)
        if codepoint <= 0xFF:
            raw.append(codepoint)
            continue
        try:
            raw.extend(char.encode('windows-1252'))
        except UnicodeEncodeError:
            raw.extend(char.encode('utf-8'))
    return bytes(raw)


def _repair_known_controls(content: str) -> str:
    for broken, fixed in CONTROL_REPAIRS.items():
        content = content.replace(broken, fixed)
    return content


def _decode_once(content: str) -> str:
    try:
        return _to_original_bytes(content).decode('utf-8', errors='replace')
    except Exception:
        return content


def _looks_mojibake(content: str) -> bool:
    return any(marker in content for marker in MOJIBAKE_MARKERS) or '\ufffd' in content


def fix_content(content: str) -> str:
    current = _repair_known_controls(content)
    for _ in range(4):
        if not _looks_mojibake(current):
            break
        fixed = _repair_known_controls(_decode_once(current))
        if fixed == current:
            break
        current = fixed
    return current


def fix_file(path: Path) -> bool:
    content = path.read_text(encoding='utf-8')
    fixed_content = ''
    changed = False

    for line in content.split('\n'):
        if any(marker in line for marker in MOJIBAKE_MARKERS):
            fixed_line = fix_content(line)
            if fixed_line != line:
                fixed_content += fixed_line + '\n'
                changed = True
                continue
        fixed_content += line + '\n'

    if fixed_content.endswith('\n') and not content.endswith('\n'):
        fixed_content = fixed_content[:-1]

    if changed:
        shutil.copy2(path, str(path) + '.bak')
        path.write_text(fixed_content, encoding='utf-8')
        return True
    return False


def main():
    target_dirs = [
        Path('apps/mobile/lib'),
        Path('apps/mobile/assets/data'),
        Path('apps/mobile/assets/images/flashcards'),
    ]

    print('Scanning:')
    for target_dir in target_dirs:
        print(f'  {target_dir.resolve()}')

    fixed = []
    for target_dir in target_dirs:
        for file_path in target_dir.rglob('*'):
            if file_path.suffix not in {'.dart', '.json'}:
                continue
            if fix_file(file_path):
                fixed.append(file_path)
                print(f'  [FIXED] {file_path}')

    print(f'\nFixed: {len(fixed)} files')


if __name__ == '__main__':
    main()
