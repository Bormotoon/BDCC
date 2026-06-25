#!/bin/bash
# BDCC Test Runner
# Runs all smoke tests in headless -s mode (no autoloads required)
set -euo pipefail

GODOT="${GODOT_BIN:-$HOME/.local/bin/godot}"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
EXIT_CODE=0

echo "=== BDCC Test Suite ==="
echo "Godot: $GODOT"
echo "Project: $PROJECT_DIR"
echo ""

if [ ! -f "$GODOT" ]; then
	echo "ERROR: Godot binary not found at $GODOT"
	echo "Set GODOT_BIN env var or install godot"
	exit 1
fi

echo "=== Smoke Test Suite ==="
echo "Running: godot --headless -s test/run_tests_headless.gd"
if "$GODOT" --headless -s "$PROJECT_DIR/test/run_tests_headless.gd" 2>&1; then
	echo ""
	echo "=== ALL TESTS PASSED ==="
else
	EXIT_CODE=1
	echo ""
	echo "=== SOME TESTS FAILED ==="
fi

exit $EXIT_CODE
