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

ccusage is a CLI tool for tracking cloud costs and usage metrics. This flake packages ccusage v15.5.0 with Node.js 22 runtime for reproducible deployments.