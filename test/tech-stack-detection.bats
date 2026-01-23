#!/usr/bin/env bats
# Tests for detect_tech_stack() function in common-functions.sh
# Verifies detection of various technologies (v5.2.0)

# Get the directory containing this test file
SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

setup() {
  TEST_DIR=$(mktemp -d)
  source "$PROJECT_ROOT/scripts/common-functions.sh"
}

teardown() {
  cd /
  rm -rf "$TEST_DIR"
}

@test "detects Tailwind CSS" {
  echo '{"dependencies": {"tailwindcss": "^3.0.0"}}' > "$TEST_DIR/package.json"
  cd "$TEST_DIR"
  result=$(detect_tech_stack)
  [[ "$result" == *"Tailwind CSS"* ]]
}

@test "detects Turso" {
  echo '{"dependencies": {"@libsql/client": "^0.5.0"}}' > "$TEST_DIR/package.json"
  cd "$TEST_DIR"
  result=$(detect_tech_stack)
  [[ "$result" == *"Turso"* ]]
}

@test "detects NextAuth.js" {
  echo '{"dependencies": {"next-auth": "^4.0.0"}}' > "$TEST_DIR/package.json"
  cd "$TEST_DIR"
  result=$(detect_tech_stack)
  [[ "$result" == *"NextAuth.js"* ]]
}

@test "detects Auth.js" {
  echo '{"dependencies": {"@auth/core": "^0.1.0"}}' > "$TEST_DIR/package.json"
  cd "$TEST_DIR"
  result=$(detect_tech_stack)
  [[ "$result" == *"Auth.js"* ]]
}

@test "detects TanStack Query" {
  echo '{"dependencies": {"@tanstack/react-query": "^5.0.0"}}' > "$TEST_DIR/package.json"
  cd "$TEST_DIR"
  result=$(detect_tech_stack)
  [[ "$result" == *"TanStack Query"* ]]
}

@test "detects tRPC" {
  echo '{"dependencies": {"@trpc/server": "^10.0.0"}}' > "$TEST_DIR/package.json"
  cd "$TEST_DIR"
  result=$(detect_tech_stack)
  [[ "$result" == *"tRPC"* ]]
}

@test "detects Zod" {
  echo '{"dependencies": {"zod": "^3.22.0"}}' > "$TEST_DIR/package.json"
  cd "$TEST_DIR"
  result=$(detect_tech_stack)
  [[ "$result" == *"Zod"* ]]
}

@test "detects multiple technologies" {
  echo '{"dependencies": {"next": "14", "prisma": "5", "zod": "3", "tailwindcss": "3"}}' > "$TEST_DIR/package.json"
  cd "$TEST_DIR"
  result=$(detect_tech_stack)
  [[ "$result" == *"Next.js"* ]]
  [[ "$result" == *"Prisma"* ]]
  [[ "$result" == *"Zod"* ]]
  [[ "$result" == *"Tailwind CSS"* ]]
}

@test "detects existing technologies (Next.js)" {
  echo '{"dependencies": {"next": "^14.0.0"}}' > "$TEST_DIR/package.json"
  cd "$TEST_DIR"
  result=$(detect_tech_stack)
  [[ "$result" == *"Next.js"* ]]
}

@test "detects TypeScript" {
  echo '{"devDependencies": {"typescript": "^5.0.0"}}' > "$TEST_DIR/package.json"
  cd "$TEST_DIR"
  result=$(detect_tech_stack)
  [[ "$result" == *"TypeScript"* ]]
}

@test "returns empty for unknown project" {
  # No package.json or other markers
  cd "$TEST_DIR"
  result=$(detect_tech_stack)
  [ -z "$result" ]
}
