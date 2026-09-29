#!/bin/sh
# =============================================================================
# gh-credential-account.sh — git credential helper pinned to one gh account
#
# `gh auth git-credential` only ever serves the account `gh auth switch` last
# made active; asked for any other account it exits 1 and git falls through to
# prompting. This wrapper asks gh for a named account's token instead, so a
# repo authenticates as the account its gitconfig says, no matter which one is
# active. ~/.gitconfig pins the personal account and ~/.gitconfig-work swaps in
# the work one for rased-org repos, alongside the identity override.
#
# git invokes a `!`-prefixed helper as: <this script> <account> <operation>
#
#   helper = !~/.gh-credential-account.sh AhmdFahad
#
# link.sh symlinks this to ~/.gh-credential-account.sh.
# Verify inside any repo with:
#   printf 'protocol=https\nhost=github.com\n\n' | git credential fill
# =============================================================================
account="$1"
operation="$2"

# store/erase are gh's business, not ours — accept and stay quiet.
[ "$operation" = "get" ] || exit 0

token=$(gh auth token --user "$account" 2>/dev/null) || {
  echo "gh has no token for account '$account' — run: gh auth login" >&2
  exit 1
}

printf 'username=%s\npassword=%s\n' "$account" "$token"
