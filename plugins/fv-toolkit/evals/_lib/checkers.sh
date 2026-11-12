#!/usr/bin/env bash
# Shared by the effect cases. A case's fixture.sh sources this file and calls
#   install_checkers <tool>...
# The run's shell has no network and its own home directory, so the checkers go
# into .fv/ inside the workspace. The scaffold runs outside the sandbox, so the
# plugin's own installer can download them, pinned and verified.
# Set FV_EVAL_JARS to a directory that already holds the jars to skip the download.

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$LIB_DIR/../.." && pwd)"

install_checkers() {
  mkdir -p .fv
  if [ -n "${FV_EVAL_JARS:-}" ]; then
    cp "$FV_EVAL_JARS"/*.jar .fv/
  fi
  FV_HOME="$PWD/.fv" "$PLUGIN_ROOT/scripts/fv-install" "$@" >/dev/null
}

# The note that tells the agent where the checkers are.
checkers_note() {
  cat <<'MD'

## Tools on this machine
- This machine has no network access.
- The model checkers are already installed in `.fv/`. Set `FV_HOME="$PWD/.fv"` on every command that runs a checker script.
MD
}
