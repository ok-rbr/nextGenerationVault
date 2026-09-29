#!/usr/bin/env bash
# The one way to validate voidlink. Humans, agents and CI run this script, so a
# check that passes locally passes in CI for the same reason (#30).
#
# Nothing here touches a vault: the tests build their own fixture vaults in
# tmp_path, and the CLI smoke test only asks for --help. 'setup' is the only
# verb that installs anything, and 'fmt' the only one that changes files.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
cd "${REPO_ROOT}"

die() {
    printf 'check.sh: %s\n' "$*" >&2
    exit 1
}

step() {
    printf '\n=== %s ===\n' "$*"
}

require_uv() {
    command -v uv >/dev/null 2>&1 ||
        die "uv is not on PATH. Install it from https://docs.astral.sh/uv/"
}

cmd_setup() {
    require_uv
    step "setup (uv sync --frozen)"
    # exactly what uv.lock pins; fails instead of resolving a different set
    uv sync --frozen
}

cmd_fmt() {
    require_uv
    step "format (ruff format)"
    uv run ruff format .
    step "import order (ruff check --fix, import rules only)"
    uv run ruff check --select I --fix .
}

cmd_lint() {
    require_uv
    step "format check (ruff format --check)"
    uv run ruff format --check .
    step "lint (ruff check)"
    uv run ruff check .
}

cmd_test() {
    require_uv
    step "tests (pytest)"
    uv run pytest
}

cmd_cli() {
    require_uv
    step "CLI registration (vault-agent --help per command)"
    # catches what unit tests miss: a Typer command that no longer registers.
    # --help reads no configuration and no vault.
    uv run vault-agent --help >/dev/null
    local command
    for command in init health validate ingest plan review apply; do
        uv run vault-agent "${command}" --help >/dev/null ||
            die "vault-agent ${command} --help failed"
    done
    printf 'ok — vault-agent and its commands load\n'
}

cmd_shell() {
    step "shell scripts (shellcheck)"
    if ! command -v shellcheck >/dev/null 2>&1; then
        # CI sets CHECK_REQUIRE_SHELLCHECK, so a missing tool fails there
        # instead of quietly shrinking the check set
        [[ -z "${CHECK_REQUIRE_SHELLCHECK:-}" ]] || die "shellcheck is required but not installed"
        printf 'SKIP shellcheck not installed — shell scripts NOT checked\n'
        return 0
    fi
    local -a scripts
    mapfile -t scripts < <(git ls-files -- '*.sh')
    ((${#scripts[@]} == 0)) || shellcheck "${scripts[@]}"
    printf 'ok — %s shell script(s)\n' "${#scripts[@]}"
}

cmd_all() {
    cmd_lint
    cmd_shell
    cmd_test
    cmd_cli
}

usage() {
    cat <<'USAGE'
usage: scripts/check.sh <verb>

  setup   install the locked environment (uv sync --frozen)
  fmt     format and sort imports — the only verb that edits files
  lint    ruff format --check and ruff check
  shell   shellcheck every tracked *.sh
  test    pytest
  cli     vault-agent and every command load (--help only)
  all     lint, shell, test and cli — what CI runs
USAGE
}

case "${1:-}" in
    setup) cmd_setup ;;
    fmt) cmd_fmt ;;
    lint) cmd_lint ;;
    shell) cmd_shell ;;
    test) cmd_test ;;
    cli) cmd_cli ;;
    all) cmd_all ;;
    -h | --help | help) usage ;;
    *)
        usage >&2
        exit 2
        ;;
esac
