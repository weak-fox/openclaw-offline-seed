# Contributing

Thanks for your interest in improving `openclaw-offline-seed`.

This repository focuses on config-driven offline seeding for OpenClaw plugins
and skills. Contributions that improve reliability, security, and offline
repeatability are especially welcome.

## Before You Start

- Search existing issues and pull requests before opening a new one.
- For larger changes, open an issue first so we can align on scope and design.
- Be respectful and follow our [Code of Conduct](./CODE_OF_CONDUCT.md).

## Development Setup

### Prerequisites

- Docker
- Node.js (for local script checks)
- `jq` (used by shell scripts)

### Build the image locally

```bash
IMAGE=local/openclaw-offline-seed:dev \
OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:2026.3.1 \
CONFIG_PATH=config/seed-config.json \
./build.sh
```

### Optional checks before opening a PR

```bash
# Shell syntax check
sh -n build.sh scripts/*.sh
```

## Contribution Workflow

1. Fork the repo and create a topic branch from `main`.
2. Keep changes focused and atomic.
3. Update docs/examples when behavior changes.
4. Open a pull request with clear context and validation details.

## Pull Request Checklist

- [ ] Change is scoped and explained.
- [ ] Relevant docs were updated.
- [ ] Local checks were executed (at least shell syntax/build where applicable).
- [ ] Backward compatibility impact is documented (if any).

## Commit Message Guidance

Use concise, imperative commit messages, for example:

- `feat: add support for vendored plugin fallback`
- `fix: validate seed config path before docker build`
- `docs: clarify OPENCLAW_HOME_DIR alignment in README`

## Reporting Bugs

When filing a bug, please include:

- Environment (OpenClaw image tag, runtime platform, Kubernetes/Docker version)
- Steps to reproduce
- Expected behavior vs actual behavior
- Relevant logs (sanitized)

## Security Issues

Do not report security vulnerabilities in public issues.
Please follow the process in [SECURITY.md](./SECURITY.md).
