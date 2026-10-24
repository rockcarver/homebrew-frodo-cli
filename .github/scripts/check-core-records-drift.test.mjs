import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { compareRecords, fetchSiblingRecords, LOCAL_DIR, main, readLocalRecords, SIBLING } from './check-core-records-drift.mjs';
import { THIS_REPO } from './validate-decision-records.mjs';

// The weekly check that the core decision records of this tap and frodo-cli stay
// identical (check-core-records-drift.mjs, .github/workflows/core-records-drift.yml).
// The sibling is replaced by a fake GitHub contents API: nothing here touches the network.

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const A = '0003-first-record.md';
const B = '0008-second-record.md';
const C = '0002-sibling-only-record.md';
const record = (repos) => `---\nstatus: accepted\ndate: 2026-10-24\ndecision-makers:\n  - maintainers\nrepos:\n${repos.map((r) => `  - ${r}`).join('\n')}\n---\n\n# Record\n`;
const SIBLING_ONLY = record(['rockcarver/frodo-cli', 'rockcarver/frodo-lib']);
const BINDS_TAP = record(['rockcarver/frodo-cli', THIS_REPO]);

/** A fetch that answers the contents API for one folder holding `files` (name -> text). */
function fakeFetch(files, { listStatus = 200, fileStatus = 200 } = {}) {
  const calls = [];
  const impl = async (url, init) => {
    calls.push({ url, init });
    const body = (data, status) => ({ status, ok: status >= 200 && status < 300, json: async () => data, text: async () => data });
    if (url === `https://api.github.com/repos/${SIBLING.repo}/contents/${SIBLING.dir}`) {
      return body(Object.keys(files).map((name) => ({ name, type: 'file', url: `https://api.github.com/file/${name}` })), listStatus);
    }
    const name = decodeURIComponent(url.split('/').pop());
    return body(files[name], fileStatus);
  };
  impl.calls = calls;
  return impl;
}

function localRoot(files) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'core-drift-'));
  if (files) {
    const dir = path.join(root, LOCAL_DIR);
    fs.mkdirSync(dir, { recursive: true });
    for (const [name, text] of Object.entries(files)) fs.writeFileSync(path.join(dir, name), text);
  }
  return root;
}

test('readLocalRecords reads the record files and ignores everything else', () => {
  const root = localRoot({ [B]: 'b', [A]: 'a', 'README.md': 'x', 'notes.txt': 'y', 'core-1.md': 'z' });
  assert.deepEqual([...readLocalRecords(root)].sort(), [[A, 'a'], [B, 'b']]);
});
test('readLocalRecords fails when the folder does not exist', () => {
  assert.throws(() => readLocalRecords(localRoot()), /does not exist/);
});
test('readLocalRecords reads this repository\'s core folder', () => {
  const records = readLocalRecords(ROOT);
  assert.ok(records.size >= 4);
  assert.ok([...records.keys()].some((name) => name.startsWith('0018-')));
});

test('compareRecords finds no difference in identical folders', () => {
  assert.deepEqual(compareRecords(new Map([[A, 'a']]), new Map([[A, 'a']])), []);
});
test('compareRecords reports a file that differs, even by one line ending', () => {
  const problems = compareRecords(new Map([[A, 'a\n']]), new Map([[A, 'a\r\n']]));
  assert.equal(problems.length, 1);
  assert.match(problems[0], new RegExp(`${A} differs`));
});
test('compareRecords reports a file held here but missing in the sibling', () => {
  const problems = compareRecords(new Map([[A, 'a']]), new Map());
  assert.equal(problems.length, 1);
  assert.match(problems[0], new RegExp(`${A} is missing in ${SIBLING.repo}`));
});
test('compareRecords ignores a sibling record that does not bind this tap', () => {
  assert.deepEqual(compareRecords(new Map([[A, 'a']]), new Map([[A, 'a'], [C, SIBLING_ONLY]])), []);
});
test('compareRecords reports a sibling record that binds this tap but is missing here', () => {
  const problems = compareRecords(new Map([[A, 'a']]), new Map([[A, 'a'], [C, BINDS_TAP]]));
  assert.equal(problems.length, 1);
  assert.match(problems[0], new RegExp(`${C} binds this repository`));
});
test('compareRecords ignores a sibling record it cannot read', () => {
  assert.deepEqual(compareRecords(new Map([[A, 'a']]), new Map([[A, 'a'], [C, 'no front matter']])), []);
});

test('fetchSiblingRecords reads every record file through the contents API and sends the token when there is one', async () => {
  const fetchImpl = fakeFetch({ [A]: 'a', [B]: 'b', 'README.md': 'ignored' });
  const records = await fetchSiblingRecords({ token: 'T', fetchImpl });
  assert.deepEqual([...records], [[A, 'a'], [B, 'b']]);
  assert.ok(fetchImpl.calls.every((c) => c.init.headers.Authorization === 'Bearer T'));
  const anonymous = fakeFetch({ [A]: 'a' });
  await fetchSiblingRecords({ fetchImpl: anonymous });
  assert.ok(anonymous.calls.every((c) => !('Authorization' in c.init.headers)));
});
test('fetchSiblingRecords says so when the sibling has no core folder', async () => {
  await assert.rejects(fetchSiblingRecords({ fetchImpl: fakeFetch({}, { listStatus: 404 }) }), /has no docs\/decisions\/core folder/);
});
test('fetchSiblingRecords fails on any other API error, for the listing and for a file', async () => {
  await assert.rejects(fetchSiblingRecords({ fetchImpl: fakeFetch({}, { listStatus: 500 }) }), /HTTP 500/);
  await assert.rejects(fetchSiblingRecords({ fetchImpl: fakeFetch({ [A]: 'a' }, { fileStatus: 403 }) }), /HTTP 403/);
});

function run(root, fetchImpl) {
  const lines = { log: [], error: [] };
  const out = { log: (l) => lines.log.push(l), error: (l) => lines.error.push(l) };
  return main({ root, env: {}, fetchImpl, out }).then((code) => ({ code, ...lines }));
}
test('main exits 0 and says so when the records are identical', async () => {
  const result = await run(localRoot({ [A]: 'a' }), fakeFetch({ [A]: 'a', [C]: SIBLING_ONLY }));
  assert.equal(result.code, 0);
  assert.deepEqual(result.error, []);
  assert.match(result.log[0], /1 identical/);
});
test('main exits 1 with one annotation per difference and opens no issue', async () => {
  const fetchImpl = fakeFetch({ [A]: 'changed', [C]: BINDS_TAP });
  const result = await run(localRoot({ [A]: 'a', [B]: 'b' }), fetchImpl);
  assert.equal(result.code, 1);
  assert.equal(result.error.length, 3);
  assert.ok(result.error.every((l) => l.startsWith('::error::')));
  assert.ok(fetchImpl.calls.every((c) => !c.init.method || c.init.method === 'GET'));
});
test('main rejects when the sibling cannot be read', async () => {
  await assert.rejects(run(localRoot({ [A]: 'a' }), fakeFetch({}, { listStatus: 404 })), /has no/);
});
