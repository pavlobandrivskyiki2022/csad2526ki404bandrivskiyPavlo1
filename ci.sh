# Prompt: Generate a portable bash CI script that:
# - creates a clean build directory (build)
# - configures with CMake (Release)
# - builds the project
# - runs CTest with verbose output
# - exits non-zero on any failure
# Use: cmake -S . -B build, cmake --build build --config Release, ctest --test-dir build --output-on-failure
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

BUILD_DIR="build"

echo "[CI] Cleaning build dir..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "[CI] Configuring (Release)..."
cmake -S . -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release

echo "[CI] Building..."
cmake --build "$BUILD_DIR" --config Release --parallel

echo "[CI] Running tests..."
# -C Release важливо для multi-config генераторів
ctest --test-dir "$BUILD_DIR" --output-on-failure -C Release

# (необов'язково) перевіримо, що hello існує і запустимо
if [[ -x "$BUILD_DIR/hello" ]]; then
  echo "[CI] Running ./build/hello"
  "$BUILD_DIR/hello" || true
fi

echo "[CI] Done ✅"
