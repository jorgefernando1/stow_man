# Stow Man Gem Plan

## Goal
Build a Ruby gem + executable CLI (`stow-man`) to manage dotfiles apps using GNU Stow, with configuration from YAML and app packages rooted in the current directory.

## Product Scope

### Core behavior
- Use current working directory (`Dir.pwd`) as the stow package root.
- Use YAML config for runtime options.
- Support commands:
  - `add APP`
  - `list`
  - `remove APP`
  - `relink APP`
  - `relink-all`

### Configuration
- Default config file: `.stow-man.yml` in current directory
- Optional override: `--config PATH`
- YAML keys:
  - `target_dir` (required)
  - `stow_bin` (optional, default: `stow`)
  - `default_verbose` (optional, default: `0`)

### UX and command behavior
- `add APP`
  - Create `./APP` if missing.
  - Stow app to `target_dir`.
- `list`
  - Discover currently linked apps by scanning symlinks in `target_dir`.
  - Return apps whose symlink targets resolve under current directory.
- `remove APP`
  - Unstow app from `target_dir`.
  - Delete app directory `./APP`.
- `relink APP`
  - Re-stow one app.
- `relink-all`
  - Re-stow all app directories in current directory.

### Verbosity
- Support repeatable `-v` (`-vv`, `-vvv`, etc.).
- Support explicit `--verbose N`.
- Verbosity resolution order:
  1. `--verbose N`
  2. count from `-v`
  3. `default_verbose` from YAML
  4. fallback to `0`
- Map resolved level directly to stow verbosity flags.

## Technical Design

### Gem structure
- `bin/stow-man` executable
- `lib/stow_man.rb`
- `lib/stow_man/version.rb`
- `lib/stow_man/cli.rb`
- `lib/stow_man/config_loader.rb`
- `lib/stow_man/stow_runner.rb`
- `lib/stow_man/app_manager.rb`
- `lib/stow_man/errors.rb`

### Main components
- `ConfigLoader`
  - Parse YAML.
  - Validate required keys and types.
  - Apply defaults.
- `StowRunner`
  - Build/execute stow commands (`stow`, `-D`, re-stow flow).
  - Apply target dir and verbosity flags.
  - Capture exit status + error output.
- `AppManager`
  - Implement command workflows (`add/list/remove/relink/relink-all`).
  - Handle directory scanning and symlink ownership checks.
- `CLI`
  - Parse global flags and subcommands.
  - Resolve config + effective verbosity.
  - Route to manager methods.
  - Return consistent exit codes/messages.

### Safety and validation
- Reject unsafe app names (path traversal, separators, absolute paths).
- Ensure `target_dir` exists and is a directory.
- For `remove`, refuse unsafe delete targets (non-directory, symlinked directory).
- Report stow failures with clear app-specific context.

### Output and exit codes
- Human-friendly messages by default.
- Optional `--json` for `list` (optional enhancement if implemented now).
- Exit codes:
  - `0`: success
  - `1`: runtime failure
  - `2`: usage/argument error
  - `3`: config error
  - `4`: app state/safety error

## Testing Strategy (Minitest)

### Unit tests
- Config parsing/validation/defaults.
- Verbosity resolution logic.
- Stow command construction.
- App name validation and safety rules.

### Integration tests
- Temp filesystem setup with package root and target dir.
- Stub runner to verify command invocations.
- Command flow tests for:
  - add/list/remove
  - relink/relink-all
  - error paths (missing app, bad config, stow failure)

### CLI tests
- Argument parsing and command dispatch.
- Global flags (`--config`, `-v`, `--verbose`, `--dry-run`).
- Exit code correctness.

## Documentation
- README with:
  - install instructions
  - config format
  - command usage examples
  - verbosity examples
  - typical workflow from an empty directory
