# CHANGELOG.md

## [v2.3.1](https://github.com/riodelphino/macime.nvim/compare/v2.3.0...v2.3.1) (2026-02-05)

* **docs:** Remove `plist` from checkhealth (to reduce information overload)
* **docs:** Add `cjk_refresh` to checkhealth

## [v2.3.0](https://github.com/riodelphino/macime.nvim/compare/v2.2.5...v2.3.0) (2026-02-04)

* **feat!:** Adapt to `macime` v3.5.0 (Add `--cjk-refresh` option)

## [v2.2.5](https://github.com/riodelphino/macime.nvim/compare/v2.2.4...v2.2.5) (2026-02-02)

* **docs:** Refine sample config / typo
* **refactor:** Strict h.plist type
* **refactor:** Simplify checking if buf excluded
* **refactor:** Refine checkhealth plist output (Use `vim.inspect()` instead)

## [v2.2.4](https://github.com/riodelphino/macime.nvim/compare/v2.2.3...v2.2.4) (2026-01-31)

* **docs:** Refine `Breaking Changes`
* **refactor:** Change type definition of `opts.save.scope`

## [v2.2.3](https://github.com/riodelphino/macime.nvim/compare/v2.2.2...v2.2.3) (2026-01-31)

* **docs:** Update `macime` version
* **feat!:** BREAKING CHANGE! Change `opts.save.global` (boolean) -> `opts.save.scope` (string)
* **feat:** Add `opts.save.enabled`

## [v2.2.2](https://github.com/riodelphino/macime.nvim/compare/v2.2.1...v2.2.2) (2026-01-31)

* **fix!:** BREAKING CHANGE! deprecae `macime` < 3.2.2 / Add `macime` version check in `setup()` / Check plist exists
* **feat!:** BREAKING CHANGE! deprecate `macime` < 3.1.1
* **docs:** typo

## [v2.2.1](https://github.com/riodelphino/macime.nvim/compare/v2.2.0...v2.2.1) (2026-01-31)

* **docs:** Add badges
* **docs:** Add LICENSE (MIT)

## [v2.2.0](https://github.com/riodelphino/macime.nvim/compare/v2.1.3...v2.2.0) (2026-01-31)

* **feat!:** BREAKING CHANGE! Reconstruct option table

## [v2.1.3](https://github.com/riodelphino/macime.nvim/compare/v2.1.2...v2.1.3) (2026-01-31)

* **refactor:** Move options to `config.lua`
* **refactor:** Modify `macime_path`, add `status`(for macime >= v3.3.1) in checkhealth
* **docs:** Add `plist` category to checkhealth list

## [v2.1.2](https://github.com/riodelphino/macime.nvim/compare/v2.1.1...v2.1.2) (2026-01-30)

* **chore:** Refine `:checkhealth` to get plist

## [v2.1.1](https://github.com/riodelphino/macime.nvim/compare/v2.1.0...v2.1.1) (2026-01-28)

* **feat:** Add `:checkhealth`
* **docs:** Upgrade compatible `macime` version to v3.1.1 (keep v2.0.0 remained)

## [v2.1.0](https://github.com/riodelphino/macime.nvim/compare/v2.0.2...v2.1.0) (2026-01-25)

* **chore:** Add `--launchd` option adapt to `macime` v3.1.1
* **docs:** typo / line feed

## [v2.0.2](https://github.com/riodelphino/macime.nvim/compare/v2.0.1...v2.0.2) (2026-01-22)

* **fix:** Check `macimed` running only if `opts.service.enabled` is `true`
* **docs:** Refine
* **refactor:** Improve message wording and formatting

* **fix:** Recieve all chunks from pipe
* **chore:** Remove debug code
* **feat:** Add `check_health()` / Add cb arg to `send()`
* **refactor:** Change `msgs.lua` to `messages.lua`
* **revert:** Include type definitions to `init.lua` for better performance

## [v2.0.1](https://github.com/riodelphino/macime.nvim/compare/v2.0.0...v2.0.1) (2026-01-21)

* **docs:** Add recommended config
* **docs:** Modify comment for sock_path
* **docs:** Chore
* **docs:** Chore `macime` version table

## [v2.0.0](https://github.com/riodelphino/macime.nvim/compare/v1.0.6...v2.0.0) (2026-01-21)

* **feat!:** BREAKING CHANGE! Adapt to `macime` v3.x with sock
* **fix:** Adapt correctly to `macimed` service
* **docs:** Refine and add `macime` versions and specs

## [v1.0.6](https://github.com/riodelphino/macime.nvim/compare/v1.0.5...v1.0.6) (2026-01-18)

* **docs:** Reformat `CHANGELOG.md`
* **docs:** Refine TODO and Remove version

## [v1.0.5](https://github.com/riodelphino/macime.nvim/compare/v1.0.4...v1.0.5) (2026-01-11)

* **docs:** Add issues

## [v1.0.4](https://github.com/riodelphino/macime.nvim/compare/v1.0.3...v1.0.4) (2026-01-10)

* **chore:** Add checking `macime` cli exists
* **perf:** Replace `vim.jobstart()` to `vim.loop.spawn()` (slightely faster)

## [v1.0.3](https://github.com/riodelphino/macime.nvim/compare/v1.0.2...v1.0.3) (2026-01-09)

* **docs:** Chore `README.md`

## [v1.0.2](https://github.com/riodelphino/macime.nvim/compare/v1.0.1...v1.0.2) (2026-01-09)

* **docs:** Chore `README.md`

## [v1.0.1](https://github.com/riodelphino/macime.nvim/compare/v1.0.0...v1.0.1) (2026-01-09)

* **docs:** Refactor `README.md`
* **perf:** Change event from `VeryLazy` to `VimEnter` for earlier event excution
* **chore:** Add group to autocmd
* **chore:** Add pattern to autocmd
* **refactor:** Add type definitions

## [v1.0.0] - 2026-01-08

* **feat:** Enables `macime` in nvim without extra codings.
