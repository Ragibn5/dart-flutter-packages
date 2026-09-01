#!/bin/bash

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_SCRIPTS_DIR="$(cd "$SELF_DIR/../../../scripts" && pwd)"

source "$ROOT_SCRIPTS_DIR/project_utils.sh"
source "$ROOT_SCRIPTS_DIR/flutter_utils.sh"
source "$SELF_DIR/exclusions.env"

unset SELF_DIR ROOT_SCRIPTS_DIR
