# StowMan

`stow-man` is an executable Ruby gem to manage dotfile app packages using GNU Stow.

It assumes your current directory is the stow package root and uses a YAML config file to define the target directory.

## Requirements

- Ruby 3.1+
- GNU Stow available in `PATH` (or configured via `stow_bin`)

## Installation (development)

```bash
bundle install
```

Run CLI directly:

```bash
bundle exec ruby exe/stow-man --help
```

## Configuration

Create `.stow-man.yml` in your dotfiles root (current working directory when running the CLI):

```yaml
target_dir: /home/your-user
stow_bin: stow
default_verbose: 0
```

- `target_dir` (required): directory where symlinks are created
- `stow_bin` (optional): stow executable path/name, default `stow`
- `default_verbose` (optional): stow verbosity level when CLI verbosity is not passed

You can start from the sample file: `.stow-man.yml.example`.

## Commands

```bash
stow-man add APP
stow-man list
stow-man remove APP
stow-man relink APP
stow-man relink-all
```

Behavior:

- `add APP`: creates `./APP` if missing, then stows it to `target_dir`
- `list`: lists apps currently linked in `target_dir` that resolve back to current directory
- `remove APP`: unstows `APP` then removes `./APP`
- `relink APP`: re-stows one app
- `relink-all`: re-stows all non-hidden app directories in current directory

## Global options

```bash
-c, --config PATH   Path to YAML config (default: ./.stow-man.yml)
-v                  Increase verbosity by 1 (repeatable)
    --verbose N     Set explicit verbosity level
-q, --quiet         Suppress non-error output
    --dry-run       Print actions without executing
-h, --help          Show help
    --version       Show version
```

Verbosity precedence:

1. `--verbose N`
2. count from `-v` flags
3. `default_verbose` from config
4. fallback `0`

## Typical workflow

```bash
# 1) Create config
cp .stow-man.yml.example .stow-man.yml

# 2) Add an app package
bundle exec ruby exe/stow-man add nvim

# 3) Place app files inside package
mkdir -p nvim/.config
$EDITOR nvim/.config/init.lua

# 4) Link package
bundle exec ruby exe/stow-man relink nvim

# 5) Inspect linked apps
bundle exec ruby exe/stow-man list
```

## Exit codes

- `0`: success
- `1`: runtime/command failure
- `2`: usage/argument error
- `3`: config error
- `4`: app state/safety error

## Development

Run tests:

```bash
bundle exec rake test
```
