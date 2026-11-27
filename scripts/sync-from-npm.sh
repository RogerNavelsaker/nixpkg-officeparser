#!/usr/bin/env bash
# Sync manifest/package.json from npm (scripts/sync-from-npm.ts), then regenerate bun.lock and bun.nix.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
before=$(jq -r .package.version nix/package-manifest.json)
nix shell nixpkgs#bun -c bun run scripts/sync-from-npm.ts
after=$(jq -r .package.version nix/package-manifest.json)
[ "$before" != "$after" ] || { echo "up to date: $after"; exit 0; }
nix shell nixpkgs#bun -c bun install --lockfile-only
nix run github:nix-community/bun2nix -- -o bun.nix
echo "bumped $before -> $after"
