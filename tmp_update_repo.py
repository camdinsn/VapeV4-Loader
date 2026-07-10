from pathlib import Path
root = Path(r'c:\Users\Alan\Downloads\VapeV4ForRoblox-main\VapeV4ForRoblox-main')
replacements = [
    ('https://raw.githubusercontent.com/7GrandDadPGN/VapeCompiled/', 'https://raw.githubusercontent.com/camdinsn/VapeV4-Loader/'),
    ('https://github.com/7GrandDadPGN/VapeCompiled', 'https://github.com/camdinsn/VapeV4-Loader'),
    ('https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox', 'https://raw.githubusercontent.com/camdinsn/VapeV4-Loader'),
    ('https://github.com/7GrandDadPGN/VapeV4ForRoblox', 'https://github.com/camdinsn/VapeV4-Loader'),
]
allowed_suffixes = {'.lua', '.md', '.txt', '.json', '.yaml', '.yml'}
changed = []
for path in root.rglob('*'):
    if not path.is_file():
        continue
    if path.suffix.lower() not in allowed_suffixes:
        continue
    try:
        text = path.read_text(encoding='utf-8')
    except Exception:
        continue
    new_text = text
    for old, new in replacements:
        new_text = new_text.replace(old, new)
    if new_text != text:
        path.write_text(new_text, encoding='utf-8')
        changed.append(str(path.relative_to(root)))
print('CHANGED', len(changed))
for p in changed[:200]:
    print(p)
