# ccusage-flake

Nix flake for packaging [ccusage](https://www.npmjs.com/package/ccusage) CLI tool with embedded Node.js runtime.

## Usage

### Run directly
```bash
nix run github:tnmt/ccusage-flake
```

### Install in current shell
```bash
nix shell github:tnmt/ccusage-flake
ccusage --help
```

### Add to flake.nix
```nix
{
  inputs = {
    ccusage.url = "github:tnmt/ccusage-flake";
  };
}
```

### Development

#### Build locally
```bash
nix build
./result/bin/ccusage --help
```

#### Run locally
```bash
nix run
```

## About ccusage

ccusage is a CLI tool for tracking cloud costs and usage metrics. This flake packages ccusage with Node.js 22 runtime for reproducible deployments.

## Auto-update

- Mechanism: `scripts/update-ccusage.sh` fetches the latest version and SRI hash from npm and updates `version/url/sha256` in `flake.nix`.
- CI: `.github/workflows/update-ccusage.yml` runs weekly and, if changes exist, validates with `nix build` and opens a PR.

### Update manually
```bash
# Requires jq and Nix
./scripts/update-ccusage.sh
nix build   # validate the change
```

### Adjust/disable CI
- Change schedule: edit the `cron` in `.github/workflows/update-ccusage.yml`.
- Disable auto PRs: remove the workflow or comment out the `Create PR` step.
