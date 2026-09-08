# Repository guidance

## Purpose

This repository builds the personal `pepi-bazzite` bootc image from
`ghcr.io/ublue-os/bazzite-gnome:stable`. The target is a GNOME desktop on
Wayland.

Most of the repository is boilerplate from the
[Universal Blue image template](https://github.com/ublue-os/image-template).
Treat the template infrastructure as upstream code: do not refactor, document,
or modify it unless a task specifically requires that.

Make operating-system and image-layer changes here. User-level packages,
dotfiles, shell configuration, and per-user application settings belong in
`~/Development/mise/`.

## Customization surface

Focus changes on the files that define the custom image:

- `build_files/build.sh`: installs and removes RPMs, enables services, sets the
  hostname, removes unwanted base-image content, and updates dconf.
- `system_files/`: files copied into the image relative to `/`.
- `system_files/etc/dconf/db/distro.d/10-pepi-terminal`: GNOME defaults and
  preferred applications.
- `system_files/usr/lib/systemd/system/pepi-install.service`: first-boot system
  Flatpak installation.
- `system_files/usr/share/pepi-flatpaks/flatpaks`: desired system Flatpak IDs.

Keep image changes declarative and safe to repeat on every build.

- Add or remove system RPMs in `build_files/build.sh` with `dnf5`.
- Put files that must exist in the deployed system under `system_files/`,
  preserving their path relative to `/`.
- Add default system Flatpaks to
  `system_files/usr/share/pepi-flatpaks/flatpaks`. The enabled
  `pepi-install.service` installs them once on first boot.
- Put GNOME defaults in the distro dconf database and keep `dconf update` in the
  build after changing those files.
- Install systemd units under `/usr/lib/systemd/system` and explicitly enable
  units that must start on the deployed system.
- Do not add per-user configuration, files under a user's home directory, or
  mutable runtime state to the image.

The `Containerfile`, `Justfile`, `disk_config/`, `image-template.env`, and GitHub
Actions workflows are primarily inherited template machinery. Preserve their
structure and conventions. Change them only when required for a concrete image,
build, or deployment need.

## Shell and style

Build scripts and Just recipes use bash with strict error handling. Preserve the
existing `set -euo pipefail` style, adding `-x` only where command tracing is
useful.

Do not comment every change. Add comments only for genuinely non-obvious
behavior, and keep them short and inline or on one line where practical.

Prefer targeted, idempotent changes over broad cleanup. Do not rewrite template
or generated sections unrelated to the task.

## Validation

Use the smallest applicable checks:

```bash
just check
just lint
just build
```

- Run `just check` after changing the `Justfile`.
- Run `just lint` after changing bash scripts when `shellcheck` is available.
- Use `just build` for changes that need full image validation when the required
  Podman resources are available. The GitHub Actions image workflow is the
  authoritative clean build.
- Do not run disk-image or VM recipes unless the task specifically requires
  those outputs.

Never rebase or switch the host with `bootc`, publish an image, push tags, or
alter the running workstation as part of routine validation.

## Working practices

Keep changes small and reversible. Inspect the existing worktree before editing
and preserve unrelated local changes. Show the plan or diff before destructive
or wide-ranging changes.

Do not read, expose, or commit private signing keys or credentials.
`cosign.key` is intentionally ignored.

For deployment instructions, use the published GHCR image and treat a host
`bootc switch` as an explicit user action rather than an automated step.
