# TASKS

## Setup
- [x] Scaffold gem with executable `bin/stow-man`.
- [x] Add minitest setup and test helper utilities.
- [x] Define base module and error classes.

## Config and CLI
- [x] Implement `ConfigLoader` for `.stow-man.yml`.
- [x] Validate required `target_dir` and optional keys (`stow_bin`, `default_verbose`).
- [x] Implement global flags: `--config`, `-v`, `--verbose`, `--quiet`, `--dry-run`, `--help`, `--version`.
- [x] Implement verbosity precedence and mapping to stow flags.

## Stow integration
- [x] Implement `StowRunner` for stow/unstow/relink flows.
- [x] Add command execution error handling and status propagation.
- [x] Add optional dry-run behavior.

## App management commands
- [x] Implement `add APP` (create app folder + stow).
- [x] Implement `list` (derive linked apps from live symlinks in `target_dir`).
- [x] Implement `remove APP` (unstow + delete app directory safely).
- [x] Implement `relink APP`.
- [x] Implement `relink-all` for all app directories in current folder.
- [x] Add app name/safety validation (no traversal, no absolute paths).

## Tests (Minitest)
- [x] Unit tests: config loader validation/defaults.
- [x] Unit tests: verbosity resolution and flag generation.
- [x] Unit tests: app name validation/safety checks.
- [x] Unit tests: stow command construction for all operations.
- [x] Integration tests: add/list/remove flows in temp dirs.
- [x] Integration tests: relink/relink-all flows.
- [x] Integration tests: error scenarios and exit codes.
- [x] CLI tests: argument parsing and command dispatch.

## Docs and finish
- [x] Write README with config, commands, examples, and troubleshooting.
- [x] Add sample `.stow-man.yml`.
- [x] Run test suite and fix failures.
- [x] Perform CLI smoke test with a temporary dotfiles folder.
