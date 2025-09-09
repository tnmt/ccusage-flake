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

## 自動アップデート（追従）

- 仕組み: `scripts/update-ccusage.sh` が npm の最新バージョンとハッシュを取得し、`flake.nix` の `version/url/sha256` を更新します。
- CI: `.github/workflows/update-ccusage.yml` が毎週実行し、変更があればビルド検証後に PR を自動作成します。

### 手動で更新する場合
```bash
# jq と Nix が必要です
./scripts/update-ccusage.sh
nix build   # 変更があればビルド検証
```

### CI を無効化/調整
- スケジュール変更: `.github/workflows/update-ccusage.yml` の `cron` を編集してください。
- 自動 PR 無効化: ワークフローを削除するか、`Create PR` ステップをコメントアウトしてください。
