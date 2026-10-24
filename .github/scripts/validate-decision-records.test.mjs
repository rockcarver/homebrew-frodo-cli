import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { validateDecisionRecords, THIS_REPO } from './validate-decision-records.mjs';

const RECORD = (n, extra = {}) => {
  const fm = {
    status: 'accepted',
    date: '2026-10-24',
    list_decision_makers: ['maintainers'],
    list_repos: ['rockcarver/frodo-cli'],
    ...extra,
  };
  const lines = ['---', `status: ${fm.status}`, `date: ${fm.date}`, 'decision-makers:', ...fm.list_decision_makers.map((x) => `  - ${x}`), 'repos:', ...fm.list_repos.map((x) => `  - ${x}`), '---', '', `# Record ${n}`, '', '## Context and problem statement', '', 'Why.', '', '## Decision', '', 'What.', '', '## Consequences', '', 'So what.', ''];
  return lines.join('\n');
};
const README = (rows) => ['# Decisions', '', '| # | Title | Status |', '| - | - | - |', ...rows, ''].join('\n');

function fixture(mutate = () => {}) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'decisions-'));
  const files = {
    'template.md': '---\nstatus: proposed\n---\n',
    '0001-first-thing.md': RECORD(1),
    '0002-second-thing.md': RECORD(2),
    'README.md': README(['| 0001 | [First](0001-first-thing.md) | accepted |', '| 0002 | [Second](0002-second-thing.md) | accepted |']),
  };
  mutate(files);
  for (const [name, text] of Object.entries(files)) if (text !== null) fs.writeFileSync(path.join(dir, name), text);
  return dir;
}
const check = (mutate, opts = {}) => validateDecisionRecords({ dir: fixture(mutate), ...opts });
const has = (problems, text) => assert.ok(problems.some((p) => p.includes(text)), `expected a problem containing "${text}", got: ${JSON.stringify(problems)}`);

test('a valid set of records has no problems', () => {
  assert.deepEqual(check(() => {}, { requireRepos: true }), []);
});
test('a missing directory is a problem', () => has(validateDecisionRecords({ dir: '/nonexistent-decisions-dir' }), 'does not exist'));
test('README.md and template.md are required', () => {
  has(check((f) => { f['README.md'] = null; }), 'README.md is missing');
  has(check((f) => { f['template.md'] = null; }), 'template.md is missing');
});
test('file names must be NNNN-short-title.md', () => has(check((f) => { f['0003_Bad Name.md'] = RECORD(3); }), 'the name must be NNNN-short-title.md'));
test('numbers must be unique and contiguous', () => {
  has(check((f) => { f['0001-other-thing.md'] = RECORD(1); }), 'used twice');
  has(check((f) => { f['0004-gap.md'] = RECORD(4); }), 'contiguous');
});
test('front matter is required and strict', () => {
  has(check((f) => { f['0001-first-thing.md'] = 'no front matter\n'; }), 'must start with a front matter block');
  has(check((f) => { f['0001-first-thing.md'] = RECORD(1).replace('status: accepted\n', ''); }), 'missing front matter key "status"');
  has(check((f) => { f['0001-first-thing.md'] = RECORD(1).replace('date: 2026-10-24', 'date: 2026-02-30'); }), 'real YYYY-MM-DD date');
  has(check((f) => { f['0001-first-thing.md'] = RECORD(1).replace('status: accepted', 'status: maybe'); }), 'must be one of');
  has(check((f) => { f['0001-first-thing.md'] = RECORD(1).replace('date: 2026-10-24\n', 'date: 2026-10-24\nowner: me\n'); }), 'unknown front matter key');
  has(check((f) => { f['0001-first-thing.md'] = RECORD(1).replace('decision-makers:\n  - maintainers', 'decision-makers: maintainers'); }), 'must be a list');
  has(check((f) => { f['0001-first-thing.md'] = RECORD(1).replace('status: accepted', 'status: accepted\nstatus: proposed'); }), 'duplicate key');
});
test('repos is required only when asked', () => {
  const noRepos = (f) => { f['0001-first-thing.md'] = RECORD(1).replace('repos:\n  - rockcarver/frodo-cli\n', ''); };
  assert.deepEqual(check(noRepos), []);
  has(check(noRepos, { requireRepos: true }), 'missing front matter key "repos"');
});
test('superseded records must name an existing, different record', () => {
  const sup = (to) => (f) => { f['0001-first-thing.md'] = RECORD(1, { status: `superseded by ${to}` }); f['README.md'] = README([`| 0001 | [First](0001-first-thing.md) | superseded by ${to} |`, '| 0002 | [Second](0002-second-thing.md) | accepted |']); };
  assert.deepEqual(check(sup('0002')), []);
  has(check(sup('0009')), 'which does not exist');
  has(check(sup('0001')), 'cannot supersede itself');
});
test('the body needs a title and the three sections in order, each with content', () => {
  has(check((f) => { f['0001-first-thing.md'] = RECORD(1).replace('# Record 1', 'Record 1'); }), 'must start with a "# Title"');
  has(check((f) => { f['0001-first-thing.md'] = RECORD(1).replace('## Decision', '## Outcome'); }), 'unknown section');
  has(check((f) => { f['0001-first-thing.md'] = RECORD(1).replace(/## Consequences[\s\S]*/, ''); }), 'missing section "## Consequences"');
  assert.deepEqual(check((f) => { f['0001-first-thing.md'] = RECORD(1) + '\n## Known deviations\n\nSee 0002.\n\n## Alternatives considered\n\nNone.\n'; }), []);
  has(check((f) => { f['0001-first-thing.md'] = RECORD(1).replace('## Consequences', '## Known deviations\n\nEarly.\n\n## Consequences'); }), 'out of order');
  has(check((f) => { f['0001-first-thing.md'] = RECORD(1).replace('## Decision\n\nWhat.\n\n## Consequences\n\nSo what.\n', '## Consequences\n\nSo what.\n\n## Decision\n\nWhat.\n'); }), 'out of order');
  has(check((f) => { f['0001-first-thing.md'] = RECORD(1).replace('What.', ''); }), 'is empty');
});
test('records stay short and carry no credentials', () => {
  has(check((f) => { f['0001-first-thing.md'] = RECORD(1) + 'filler\n'.repeat(70); }), 'longer than');
  has(check((f) => { f['0001-first-thing.md'] = RECORD(1) + 'token ghp_' + 'a'.repeat(30) + '\n'; }), 'credential');
});
test('the README index lists every record with its status and nothing else', () => {
  has(check((f) => { f['README.md'] = README(['| 0001 | [First](0001-first-thing.md) | accepted |']); }), 'no row linking 0002-second-thing.md');
  has(check((f) => { f['README.md'] = README(['| 0001 | [First](0001-first-thing.md) | proposed |', '| 0002 | [Second](0002-second-thing.md) | accepted |']); }), 'does not show the status');
  has(check((f) => { f['README.md'] = README(['| 0001 | [First](0001-first-thing.md) | accepted |', '| 0002 | [Second](0002-second-thing.md) | accepted |', '| 0003 | [Ghost](0003-ghost.md) | accepted |']); }), 'which does not exist');
});

// Core records (core 0018): one identical file per repository it binds, held in <dir>/core.
// This repository holds only the ones that bind it plus core 0018, so numbers have gaps.
const TAP = THIS_REPO;
const CORE_ROW = (n, file, status = 'accepted') => `| [core ${n}](core/${file}) | T | ${status} | repository-wide | r |`;
const CORE_README = (rows, intro = '') => ['# Decisions', '', intro, '', '## Core decisions', '', '| Number | Title | Status | Applies to | Rule |', '| - | - | - | - | - |', ...rows, '', '## Index', '', '| # | Title | Status |', '| - | - | - |', ''].join('\n');
const CORE_FILES = { '0003-third-thing.md': RECORD(3, { list_repos: ['rockcarver/frodo-cli', TAP] }), '0018-rule-thing.md': RECORD(18, { list_repos: ['rockcarver/frodo-cli', 'rockcarver/frodo-lib'] }) };
const CORE_ROWS = [CORE_ROW('0003', '0003-third-thing.md'), CORE_ROW('0018', '0018-rule-thing.md')];

function coreFixture(mutate = () => {}) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'decisions-core-'));
  fs.mkdirSync(path.join(dir, 'core'));
  const files = { 'template.md': '---\nstatus: proposed\n---\n', 'README.md': CORE_README([...CORE_ROWS]) };
  const core = { ...CORE_FILES };
  mutate(files, core);
  for (const [name, text] of Object.entries(files)) if (text !== null) fs.writeFileSync(path.join(dir, name), text);
  for (const [name, text] of Object.entries(core)) if (text !== null) fs.writeFileSync(path.join(dir, 'core', name), text);
  return dir;
}
const checkCore = (mutate) => validateDecisionRecords({ dir: coreFixture(mutate) });

test('core: a folder with the records that bind this tap and core 0018 is valid, gaps and all', () => {
  assert.deepEqual(checkCore(() => {}), []);
});
test('core: a directory without core/ is checked as before', () => {
  assert.deepEqual(check(() => {}), []);
});
test('core: its numbers are apart from the repository\'s own records', () => {
  const dir = coreFixture((f) => {
    f['0001-own-thing.md'] = RECORD(1);
    f['README.md'] = CORE_README(CORE_ROWS).replace('| - | - | - |\n', '| - | - | - |\n| 0001 | [Own](0001-own-thing.md) | accepted |\n');
  });
  assert.deepEqual(validateDecisionRecords({ dir }), []);
});
test('core: core 0018, the rule for core records, must be held', () => {
  has(checkCore((f, c) => { delete c['0018-rule-thing.md']; f['README.md'] = CORE_README([CORE_ROWS[0]]); }), 'core 0018, the rule for core records, is missing');
});
test('core: file names and numbers', () => {
  has(checkCore((f, c) => { c['0009_Bad Name.md'] = RECORD(9); }), 'the name must be NNNN-short-title.md');
  has(checkCore((f, c) => { c['0003-other-thing.md'] = RECORD(3, { list_repos: [TAP] }); f['README.md'] = CORE_README([...CORE_ROWS, CORE_ROW('0003', '0003-other-thing.md')]); }), 'used twice');
});
test('core: front matter is as strict as for the repository\'s own records, and repos is required', () => {
  has(checkCore((f, c) => { c['0003-third-thing.md'] = 'no front matter\n'; }), 'must start with a front matter block');
  has(checkCore((f, c) => { c['0003-third-thing.md'] = c['0003-third-thing.md'].replace(/repos:[\s\S]*?\n---/, '---'); }), 'missing front matter key "repos"');
  has(checkCore((f, c) => { c['0003-third-thing.md'] = c['0003-third-thing.md'].replace('date: 2026-10-24', 'date: 2026-02-30'); }), 'real YYYY-MM-DD date');
  has(checkCore((f, c) => { c['0003-third-thing.md'] = c['0003-third-thing.md'].replace('status: accepted', 'status: maybe'); f['README.md'] = CORE_README([CORE_ROW('0003', '0003-third-thing.md', 'maybe'), CORE_ROWS[1]]); }), 'must be one of');
});
test('core: repos names must be well formed and list this tap (except core 0018)', () => {
  has(checkCore((f, c) => { c['0003-third-thing.md'] = RECORD(3, { list_repos: ['rockcarver/frodo-cli', TAP, 'not a repo'] }); }), 'must be owner/name');
  has(checkCore((f, c) => { c['0003-third-thing.md'] = RECORD(3, { list_repos: ['rockcarver/frodo-cli', 'rockcarver/frodo-lib'] }); }), `does not list ${TAP}`);
  assert.deepEqual(checkCore((f, c) => { c['0018-rule-thing.md'] = RECORD(18, { list_repos: ['rockcarver/frodo-cli'] }); }), []);
});
test('core: a record may be superseded by one this repository does not hold', () => {
  const superseded = (c) => { c['0003-third-thing.md'] = RECORD(3, { status: 'superseded by 0042', list_repos: [TAP] }); };
  assert.deepEqual(checkCore((f, c) => { superseded(c); f['README.md'] = CORE_README([CORE_ROW('0003', '0003-third-thing.md', 'superseded by 0042'), CORE_ROWS[1]]); }), []);
  has(checkCore((f, c) => { c['0003-third-thing.md'] = RECORD(3, { status: 'superseded by 0003', list_repos: [TAP] }); f['README.md'] = CORE_README([CORE_ROW('0003', '0003-third-thing.md', 'superseded by 0003'), CORE_ROWS[1]]); }), 'cannot supersede itself');
});
test('core: records stay short and carry no credentials', () => {
  has(checkCore((f, c) => { c['0003-third-thing.md'] += 'filler\n'.repeat(70); }), 'longer than');
  has(checkCore((f, c) => { c['0003-third-thing.md'] += 'token ghp_' + 'a'.repeat(30) + '\n'; }), 'credential');
});
test('core: the "Core decisions" table lists every core file with its status and nothing else', () => {
  has(checkCore((f) => { f['README.md'] = CORE_README([CORE_ROWS[1]]); }), 'has no row linking core/0003-third-thing.md');
  has(checkCore((f) => { f['README.md'] = CORE_README([CORE_ROW('0003', '0003-third-thing.md', 'proposed'), CORE_ROWS[1]]); }), 'does not show the status "accepted"');
  has(checkCore((f) => { f['README.md'] = CORE_README([...CORE_ROWS, CORE_ROW('0099', '0099-ghost.md')]); }), 'links core/0099-ghost.md, which does not exist');
});
test('core: a link in the text above the table does not count as the row', () => {
  const link = '[core 0003](core/0003-third-thing.md)';
  has(checkCore((f) => { f['README.md'] = CORE_README([CORE_ROWS[1]], `See ${link}.`); }), 'has no row linking core/0003-third-thing.md');
  assert.deepEqual(checkCore((f) => { f['README.md'] = CORE_README(CORE_ROWS, `See ${link}.`); }), []);
});

// A Known deviations section is a status note (core 0018): pin the real files.
const REAL = (rel) => fs.readFileSync(fileURLToPath(new URL(`../../${rel}`, import.meta.url)), 'utf8');
test('known deviations: core 0018 lets the pull request that fixes a deviation edit or remove it', () => {
  const rule = REAL('docs/decisions/core/0018-core-decision-records-are-kept-in-each-repository.md');
  assert.match(rule, /status note, not part of the decision/);
  assert.match(rule, /tracking issue and the commit it was written against/);
  assert.match(rule, /added, edited or removed, without a new record, in the pull request that fixes the deviation or opens its tracking issue/);
  assert.match(rule, /Nothing else in an accepted record changes\./);
  assert.match(rule, /The one exception is a Known deviations section/);
});
test('known deviations: the README rule names the exception and links core 0018', () => {
  const readme = REAL('docs/decisions/README.md');
  const line = readme.split('\n').find((l) => l.startsWith('- An accepted record is not edited')) ?? '';
  assert.match(line, /except for typos and for a `Known deviations` section/);
  assert.match(line, /\]\(core\/0018-core-decision-records-are-kept-in-each-repository\.md\)/);
  const row = readme.split('\n').find((l) => /^\|\s*\[core 0018\]\(/.test(l)) ?? '';
  assert.match(row, /Known deviations section is a status note/);
});
