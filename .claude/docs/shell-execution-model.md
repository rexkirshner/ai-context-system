# Shell Execution Model

**Version:** v5.2.0
**Purpose:** Document how bash blocks execute in AI Context System commands

---

## Key Principle

Each bash block in a command file runs in an **isolated shell**.
Variables, functions, and exports do NOT persist between blocks.

This is a fundamental characteristic of how Claude Code (and similar tools) execute shell commands.

---

## Self-Contained Block Pattern

Every bash block must be independently executable:

```bash
# === SELF-CONTAINED BLOCK ===
# 1. Source dependencies (if needed)
source scripts/common-functions.sh 2>/dev/null || {
  echo "Error: common-functions.sh not found"
  exit 1
}

# 2. Define all required variables
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
CONFIG_FILE="$PROJECT_ROOT/context/.context-config.json"

# 3. Validate prerequisites
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Config file not found: $CONFIG_FILE"
  exit 1
fi

# 4. Execute step logic
# ... actual work here ...
```

### Why Self-Contained?

1. **No shared shell state** - Each block starts fresh
2. **No environment inheritance** - Previous exports don't persist
3. **No function persistence** - Functions must be re-sourced
4. **Predictable execution** - Each block works independently

---

## Anti-Patterns

### DON'T: Assume variables from previous blocks exist

```bash
# Block 1
export MY_VAR="value"

# Block 2 - WRONG: MY_VAR won't exist!
echo $MY_VAR  # Empty or error
```

### DON'T: Assume functions are defined

```bash
# Block 1
my_function() { echo "hello"; }

# Block 2 - WRONG: my_function doesn't exist!
my_function  # command not found
```

### DON'T: Rely on cd from previous blocks

```bash
# Block 1
cd /some/directory

# Block 2 - WRONG: pwd is back to original!
pwd  # Not /some/directory
```

---

## Correct Patterns

### DO: Re-establish context in each block

```bash
# Block 1
MY_VAR="value"
echo "$MY_VAR" > /tmp/my_var.txt
echo "Set MY_VAR to: $MY_VAR"

# Block 2 - Read from file if needed
MY_VAR=$(cat /tmp/my_var.txt 2>/dev/null || echo "default")
echo "Got MY_VAR: $MY_VAR"
```

### DO: Source common functions in each block that needs them

```bash
# Block 1
source scripts/common-functions.sh || exit 1
result=$(get_project_root)
echo "$result"

# Block 2 - Source again!
source scripts/common-functions.sh || exit 1
another_result=$(get_max_session_number)
echo "$another_result"
```

### DO: Use absolute paths or re-find directories

```bash
# Block 1
PROJECT_ROOT=$(pwd)
echo "Working in: $PROJECT_ROOT"

# Block 2 - Find root again
PROJECT_ROOT=$(find_project_root 2>/dev/null || pwd)
cd "$PROJECT_ROOT"
echo "Back in: $PROJECT_ROOT"
```

---

## State Persistence Strategies

### Strategy 1: Temporary Files

For simple values:
```bash
echo "$VALUE" > /tmp/acs_value.txt

# Later block:
VALUE=$(cat /tmp/acs_value.txt)
```

### Strategy 2: Environment Files

For multiple values:
```bash
cat > /tmp/acs_env.sh << EOF
export PROJECT_ROOT="$PROJECT_ROOT"
export CONFIG_FILE="$CONFIG_FILE"
export SESSION_NUM="$SESSION_NUM"
EOF

# Later block:
source /tmp/acs_env.sh
```

### Strategy 3: Re-Detection

For values that can be computed:
```bash
# Each block detects what it needs
PROJECT_ROOT=$(find_project_root)
CONFIG_FILE="$PROJECT_ROOT/context/.context-config.json"
SESSION_NUM=$(get_next_session_number)
```

This is often the cleanest approach - it's idempotent and doesn't require file cleanup.

---

## Command File Structure

### Recommended Structure

```markdown
# /command-name Command

> **Execution Model:** Each bash block runs in an isolated shell.
> Variables do not persist between blocks. See `.claude/docs/shell-execution-model.md`.

## Step 1: Setup

```bash
# Self-contained: sources and defines what it needs
source scripts/common-functions.sh || exit 1
PROJECT_ROOT=$(find_project_root)
# ... step logic ...
```

## Step 2: Process

```bash
# Self-contained: doesn't assume Step 1's variables exist
source scripts/common-functions.sh || exit 1
PROJECT_ROOT=$(find_project_root)
# ... step logic ...
```
```

### Header Note

All command files should include this note near the top:

```markdown
> **Execution Model:** Each bash block runs in an isolated shell.
> Variables do not persist between blocks. See `.claude/docs/shell-execution-model.md`.
```

---

## Debugging Tips

### Symptom: Variable is empty

**Cause:** Variable set in previous block, expected here
**Fix:** Re-define or re-detect the variable in this block

### Symptom: Function not found

**Cause:** Function defined in previous block or not sourced
**Fix:** Add `source scripts/common-functions.sh` at start of block

### Symptom: Wrong directory

**Cause:** `cd` in previous block doesn't persist
**Fix:** Use absolute paths or `cd` again in current block

### Symptom: Script worked once but fails on retry

**Cause:** Temporary file from previous run not cleaned up
**Fix:** Use unique temp file names or clean up in each block

---

## Testing Self-Containment

To verify a bash block is self-contained, copy it to a new terminal and run it. If it works without running previous blocks, it's properly self-contained.

```bash
# Test: Copy just this block to a fresh terminal
source scripts/common-functions.sh || exit 1
PROJECT_ROOT=$(find_project_root)
echo "Project root: $PROJECT_ROOT"
# Should work in isolation
```

---

## Related Documentation

- [common-functions.sh](/scripts/common-functions.sh) - Shared shell functions
- [Command Philosophy](/docs/command-philosophy.md) - Design principles
