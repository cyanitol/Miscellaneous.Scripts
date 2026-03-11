# Repository Guidelines

## Project Structure & Module Organization
- `src/sh/` contains all shell scripts. Each script is standalone and named with a `Bash.<Domain>.<Action>.sh` pattern.
- `src/go/` contains Go code, including the restic wrapper CLI.
- `README.md` lists available scripts and brief descriptions.
- No dedicated test or build directories exist in this repository.

## Build, Test, and Development Commands
- `bash src/sh/Bash.Backup.Restic.sh` runs the Restic backup flow (requires Restic and valid B2 credentials).
- `bash src/sh/Bash.Firewall.UFW.Harden.sh` applies UFW rules (requires root and `ufw`, `dig`).
- `bash src/sh/Bash.Git.UpdateRepository.sh` updates remotes for local repos (requires `git` installed and a valid path).
- `bash src/sh/Bash.WebServer.Caddy.RenewCertificate.sh` toggles UFW rules and restarts Caddy (requires root, `ufw`, and `systemctl`).

## Coding Style & Naming Conventions
- Shell: Bash with `#!/bin/bash` shebangs and uppercase environment variables.
- Indentation: 4 spaces for function bodies and loops.
- Naming: files use `Bash.<Area>.<Verb>.sh`; functions use `CamelCase()`; variables are `UPPER_SNAKE` for config and `lowerCamel` for locals.
- Keep scripts readable and self-contained; prefer explicit paths and comment key steps.

## Testing Guidelines
- No automated test framework is present.
- Validate changes by running the specific script in a safe environment (e.g., a VM) and confirming expected side effects (UFW rules, Caddy restart, Restic output).

## Commit & Pull Request Guidelines
- Git history is not available in this environment (no `git` binary), so commit conventions are unknown.
- Recommended: short, imperative commit messages (e.g., "Harden UFW rules"), and PRs with a brief description, affected scripts, and any required privileges or environment dependencies.

## Security & Configuration Tips
- Many scripts require root privileges and may change firewall rules; review variables like `DNS_record`, `allowed_ports`, and paths before running.
- Replace placeholder paths and credentials (e.g., Restic repository, B2 keys, log paths) before use.
