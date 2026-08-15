# ff

`ff` runs a one-time command as a detached systemd user service, records its output in the journal, and sends a desktop notification when it finishes.

It is intended for commands that should keep running after their originating terminal closes but do not need interactive input.

## Requirements

- Bash 5+
- systemd user services (`systemd-run`, `systemctl`, and `journalctl`)
- `omarchy notification send` or `notify-send` for completion notifications

## Install

From the repository:

```bash
./install.sh
```

The installer creates `~/.local/bin/ff` as a symlink to this checkout. It refuses to replace an unrelated existing file.

If your shell already defines an alias named `ff`, the alias takes precedence over the installed executable. Rename or remove that alias after it is loaded. For example, Omarchy's Zsh defaults use `ff` for an `fzf` preview shortcut; that shortcut can be preserved under another name:

```zsh
if (( $+aliases[ff] )); then
  alias fff="${aliases[ff]}"
  unalias ff
fi
```

## Usage

```bash
ff sleep 30
ff --name tests dotnet test
ff --env AWS_PROFILE -- terraform apply -auto-approve
ff --shell 'dotnet test && dotnet publish'
```

Commands are passed as an argument array by default, so spaces and literal shell characters are preserved safely. Use `--shell` only when pipelines, redirections, variable expansion, or other shell syntax are needed.

`--shell` uses `$SHELL -lc`. A login shell does not generally load interactive aliases or functions.

### Inspect and manage jobs

```bash
ff --list
ff --last
ff --status                 # most recent job
ff --logs                   # most recent job
ff --logs JOB --follow
ff --cancel JOB
ff --clean
```

Successful transient units are eligible for automatic cleanup by systemd. Failed units remain inspectable until `ff --clean`; their journal logs remain available afterward.

## Environment

Detached user services receive the user service manager's environment rather than the complete environment of the launching terminal. `ff` automatically forwards `PATH`, `SSH_AUTH_SOCK`, and `DOTNET_ROOT` when set.

Forward additional variables explicitly:

```bash
ff --env AWS_PROFILE aws s3 sync ./build s3://example
ff --env API_URL=https://example.test ./deploy
```

## Limitations

Do not use `ff` for commands that need terminal input, confirmation prompts, or an interactive `sudo` password. Such a command will wait invisibly for input. Run those commands in a normal terminal.

Jobs survive closing the originating terminal. Whether they survive logout depends on the system's user-manager lingering configuration; they do not survive a reboot.

## Development

```bash
./tests/test.sh
```
