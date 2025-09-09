#!/usr/bin/env sh
set -eu

# Update ccusage version and sha256 in flake.nix to the latest from npm.

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

if ! command -v jq >/dev/null 2>&1; then
  echo "[update-ccusage] jq が見つかりません。jq をインストールしてください。" >&2
  exit 1
fi

current_version=$(awk -F '"' '/version = "/{print $2; exit}' flake.nix)
current_url=$(awk -F '"' '/url = "https:\/\/registry.npmjs.org\/ccusage\/-\/ccusage-/{print $2; exit}' flake.nix || true)
current_sha=$(awk -F '"' '/sha256 = "/{print $2; exit}' flake.nix)

echo "[update-ccusage] 現在のバージョン: ${current_version}"

meta_json=$(curl -fsSL https://registry.npmjs.org/ccusage/latest)
latest_version=$(echo "$meta_json" | jq -r .version)
tarball_url=$(echo "$meta_json" | jq -r .dist.tarball)

echo "[update-ccusage] 最新のバージョン: ${latest_version}"

if [ -z "$latest_version" ] || [ "$latest_version" = "null" ]; then
  echo "[update-ccusage] 最新版の取得に失敗しました" >&2
  exit 1
fi

# バージョンが同一でもURL/ハッシュ差分があれば更新を続行

# Prefetch SRI hash usable in flake.nix (sha256-...) for fetchzip (unpacked hash)
echo "[update-ccusage] ハッシュを事前取得: ${tarball_url}"

# Try modern Nix prefetch with --unpack first
hash_sri=""
if nix store prefetch-file --help 2>&1 | grep -q -- "--unpack"; then
  hash_sri=$(nix store prefetch-file --json --unpack "$tarball_url" | jq -r .hash || true)
fi

# Fallback to nix-prefetch-url --unpack and convert to SRI
if [ -z "$hash_sri" ] || [ "$hash_sri" = "null" ]; then
  if command -v nix-prefetch-url >/dev/null 2>&1; then
    base32=$(nix-prefetch-url --unpack "$tarball_url")
    if command -v nix >/dev/null 2>&1; then
      hash_sri=$(nix hash to-sri --type sha256 "$base32")
    fi
  fi
fi

if [ -z "$hash_sri" ]; then
  echo "[update-ccusage] ハッシュの取得に失敗しました" >&2
  exit 1
fi

echo "[update-ccusage] 取得ハッシュ: ${hash_sri}"

# Update flake.nix in-place using env vars to avoid shell quoting issues
LATEST_VERSION="$latest_version" \
TARBALL_URL="$tarball_url" \
HASH_SRI="$hash_sri" \
perl -0777 -i -pe '
  s/version = "[^"]+";/version = "$ENV{LATEST_VERSION}";/g;
  s|url = "https://registry\.npmjs\.org/ccusage/-/ccusage-[^"]+\.tgz";|url = "$ENV{TARBALL_URL}";|g;
  s|sha256 = "sha256-[^"]+";|sha256 = "$ENV{HASH_SRI}";|g;
' flake.nix

echo "[update-ccusage] flake.nix を更新しました: ${current_version} -> ${latest_version}"

exit 0
