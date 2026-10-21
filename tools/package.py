"""Build an installable ZIP from the explicit manifest and verify every byte."""
from pathlib import Path
import hashlib
import json
import re
import zipfile

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / 'release-manifest.json').read_text())
addon = manifest['addon']
files = manifest['files']
if len(files) != len(set(files)):
    raise SystemExit('Duplicate manifest entry')
for relative in files:
    path = root / relative
    if path.is_symlink() or not path.is_file() or not path.resolve().is_relative_to((root / addon).resolve()):
        raise SystemExit('Invalid package path: ' + relative)
actual = {p.relative_to(root).as_posix() for p in (root / addon).rglob('*') if p.is_file()}
if actual != set(files):
    raise SystemExit('Manifest does not match runtime files')
versions = set()
for toc in (root / addon).glob('*.toc'):
    text = toc.read_text(encoding='utf-8-sig')
    versions.add(re.search(r'^## Version: (.+)$', text, re.M).group(1).strip())
    for line in text.splitlines():
        line = line.strip()
        if line and not line.startswith('#') and addon + '/' + line.replace('\\', '/') not in files:
            raise SystemExit('Missing TOC file: ' + line)
if len(versions) != 1:
    raise SystemExit('TOC versions disagree')
version = versions.pop()
if not re.fullmatch(r'[0-9]+\.[0-9]+\.[0-9]+(?:-[a-z0-9.-]+)?', version):
    raise SystemExit('Unexpected version')
dist = root / 'dist'
dist.mkdir(exist_ok=True)
archive = dist / ('ChasmGuide-' + version + '.zip')
with zipfile.ZipFile(archive, 'w') as output:
    for relative in sorted(files):
        info = zipfile.ZipInfo(relative, (2026, 1, 1, 0, 0, 0))
        info.create_system = 3
        info.external_attr = 0o100644 << 16
        info.compress_type = zipfile.ZIP_DEFLATED
        output.writestr(info, (root / relative).read_bytes())
with zipfile.ZipFile(archive) as output:
    assert set(output.namelist()) == set(files)
    for relative in files:
        assert output.read(relative) == (root / relative).read_bytes()
digest = hashlib.sha256(archive.read_bytes()).hexdigest()
(dist / 'SHA256SUMS.txt').write_text(digest + '  ' + archive.name + '\n', encoding='utf-8', newline='\n')
print('Verified ' + archive.name + ', ' + str(len(files)) + ' files, SHA256 ' + digest)
