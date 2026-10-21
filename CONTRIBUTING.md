# Contributing

Use Node.js 24 and Python 3.11 or newer. From the repository root, run:

```sh
npm ci --ignore-scripts
npm test
python -m pip install -r requirements-test.txt
python tests/test_routes.py
python tests/test_migration.py
python tools/package.py
```

The tests use mocked game APIs. Report live gameplay checks separately, with the client build, faction and dungeon. Preserve default-off automation and saved progress when changing routes. The migration suite compares current behavior with the 1.2.1 fixtures in tests/fixtures.

Open a pull request with the problem, resulting behavior and checks you ran. Preserve contributor credits and data-source notices. Add source links when correcting quest facts. Never commit WTF, saved variables, account names, local installation paths or screenshots containing private chat.

The builder uses release-manifest.json and verifies every packaged file. It writes the installable ZIP and SHA256SUMS.txt into dist. Tag names must match the TOC version with a leading v.

The Node test runner's Fengari dependency currently pulls in sprintf-js with an unbounded-precision denial-of-service advisory, GHSA-hp3w-g68c-fv3c. These packages run only the local regression suite and are excluded from the add-on ZIP. The tests use fixed local format strings. Do not use this test runner as a service for untrusted input.
