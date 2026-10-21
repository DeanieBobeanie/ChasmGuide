from pathlib import Path
import os, re
addon = __import__('json').loads(Path('release-manifest.json').read_text())['addon']
versions = {re.search(r'^## Version: (.+)$', p.read_text(), re.M).group(1).strip() for p in Path(addon).glob('*.toc')}
if len(versions) != 1 or os.environ['RELEASE_TAG'] != 'v' + versions.pop():
    raise SystemExit('Release tag does not match TOC version')
