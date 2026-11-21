# NetNewsWire Fork — Patch Summary

_Last updated: 2026-11-21_

Personal fork of NetNewsWire (`origin` = `ShishirAravindan/NetNewsWire`, `upstream` = `Ranchero-Software/NetNewsWire`).
All three work branches are pushed to the fork and branch off upstream `7f2802112`. The local clone was deleted
on 2026-11-21; re-clone the fork to resume.

**3 work branches, 8 commits.** Personal experiments, not intended for upstream.

> **2026-11-21: Substack footnote popovers shipped upstream in 7.3** (PR #5362, `f28d204c1`, in both `mac-7.3`
> and `iOS-7.3`). `codex/substack-footnotes` is superseded for popovers. See §3 for the small gap that remains.

---

## 1. `feat/highlight-export` — Send Quote to Logseq *(1 commit, 2026-06-17)*

| Commit | Summary |
|---|---|
| `29615ba0b` | Add Send Quote to Logseq command (⌃⌥L) for the selected article text |

- Select text in an article → **⌃⌥L** (or Edit → *Send Quote to Logseq*) → appends a markdown quote
  block to **today's Logseq journal** via the `logseq://x-callback-url/quickCapture?page=TODAY&append=true` URL scheme.
- Output format:
  ```
  #+BEGIN_QUOTE
  {selected text}

  — _{author} ({feed})_ in [{article title}]({url})
  #+END_QUOTE
  ```
- Missing author → drops just the author segment, keeps the source link (`— [title](url)`).
- New testable helper `Shared/LogseqQuoteCapture.swift` (+ 6 unit tests in `Tests/NetNewsWireTests/LogseqQuoteCaptureTests.swift`).
- Files: `LogseqQuoteCapture.swift`, `LogseqQuoteCaptureTests.swift`, `MainWindowController.swift`,
  `DetailViewController.swift`, `DetailWebViewController.swift`, `Main.storyboard` (6 files, +176).
- **Status:** macOS build + tests green. Personal feature (no upstream demand — intentional).
- **Logseq-side requirement (not code):** the `[[quick capture]]` + timestamp prefix is added by Logseq's
  quick-capture template. To get the bare quote block, set in the graph's `logseq/config.edn`:
  ```edn
  :quick-capture-templates {:text "{text}"}
  ```
  (then re-index/reload the graph). This is global to the graph, affecting all quick captures.
- **Open verification:** confirm the multiline `#+BEGIN_QUOTE` lands as a *single* block (not split into
  bullets) on real quickCapture. If it splits, switch to Logseq's local HTTP API for exact multiline fidelity.

---

## 2. `keyboard-shortcut-enhancements` — Mac shortcuts *(3 commits, 2026-03-19→22)*

| Commit | Feature | Upstream relevance |
|---|---|---|
| `6668f54cf` | **Cmd+Shift+M** — copy article as Markdown link | aligns with #3482, #3786 |
| `2ccf138be` | **Option+Q** — copy quote link (text fragment `#:~:text=`) | answers #4793; iOS covered by open PR #5068 |
| `ffccf05cd` | **Cmd+S / Cmd+Shift+S** — toggle sidebar / timeline | — |

- Files: 6 changed, +102 / -4.
- ⚠️ The Option+Q commit has a **text-fragment encoding bug**: it uses `.urlFragmentAllowed`, leaving
  `, & - =` unencoded — exactly the text-fragment metacharacters — so selections containing them produce
  broken highlight links. The correct encoding now lives in `LogseqQuoteCapture` (feat/highlight-export)
  but has **not** been backported here.
- macOS already provides "Copy Link with Highlight" natively in the right-click menu (macOS 14+ WKWebView),
  so the only additive value of Option+Q is the **keyboard shortcut**, not the capability.
- Holds the stashed WIP `stash@{0}` (xcconfig warn-threshold 300→400 + untracked `Package.resolved`).

---

## 3. `codex/substack-footnotes` — Substack footnote anchors *(4 commits, 2026-02-21)*

| Commit | Summary |
|---|---|
| `def325eee` | feat: support Substack footnote anchors in popovers (`newsfoot.js`) |
| `9157fb83e` | test: renderer asserts external URL base when permalink missing |
| `078fb13a1` | test: RSParser covers Substack non-permalink footnote anchors |
| `8804d25e1` | chore: relax long-function warning threshold (xcconfig 300→400) |

- The "footnote fix" this project folder is named for. Bulk of the work is `newsfoot.js` (popover engine),
  plus RSParser parsing + ArticleRenderer, with unit tests on both. Files: 7 changed, +148 / -45.
- **Superseded upstream in 7.3** by PR #5362 (`f28d204c1`). Upstream matches `a[id^='footnote-anchor-']` and
  builds the popover from the elements after `#footnote-N`, which gives the same content as this branch's
  `.footnote-content` lookup.
- **Remaining gap in 7.3** (read from the code, not tested): clicking the number in the footnote list at the bottom
  isn't handled. Upstream's back-link selector only matches links inside a `.footnotes` container, and Substack
  uses `.footnote` divs, so the click probably navigates to `<pub>.substack.com/#footnote-anchor-N` instead of
  scrolling. This branch fixed it with the `.footnote .footnote-number[href^='#footnote-anchor-']` selector.
  7.3 also still uses the feed homepage as the base URL when the guid isn't a permalink (this branch used
  `preferredLink`).

---

## Status

- Personal experiments with an open-source codebase. **No plans to upstream any of it.**
- All branches are pushed to the fork. The local clone and the ad-hoc test files were deleted on 2026-11-21.
- Known loose end: the Option+Q text-fragment encoding bug (see §2). The correct encoding lives in
  `LogseqQuoteCapture` if this is ever picked up again.
