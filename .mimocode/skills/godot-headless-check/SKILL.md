---
name: godot-headless-check
description: Run Godot headless diagnostics, analyze errors, fix code, and commit. Enforces anti-loop discipline: max 2 diagnostic runs per code change.
---

# Godot Headless Diagnostic Cycle

Run `godot --headless` to check for compilation/runtime errors, analyze output, apply fixes, and commit. Designed for Godot 3→4 migration and ongoing error cleanup.

## Anti-Loop Rule (CRITICAL)

**Never re-run diagnostics more than 2 times without a code change.** If stuck in a loop:
1. Make ANY code change (even a stub/comment) to break the cycle
2. Commit the diagnostic output as a reference
3. Move to a different file or take a break

This anti-pattern has wasted entire sessions (documented 500+ wasted tool calls in BDCC history).

## Procedure

### Step 1: Run diagnostics (max 2x per fix cycle)

```bash
export DISPLAY=:0 && timeout 60 /home/borm/.local/bin/godot --headless --path /home/borm/VibeCoding/BDCC --quit 2>&1 | grep "SCRIPT ERROR" | grep -v "Compile Error" | grep -v "Could not find type" | head -30
```

Count total errors:
```bash
export DISPLAY=:0 && timeout 60 /home/borm/.local/bin/godot --headless --path /home/borm/VibeCoding/BDCC --quit 2>&1 | grep -c "SCRIPT ERROR"
```

### Step 2: Analyze error output

Group errors by:
1. **Root cause** — which script/autoload is the source (not just the cascade victim)
2. **Error type** — parse error, unresolved identifier, wrong API, missing method
3. **Cascade scope** — how many other scripts fail because of this one

Prioritize fixing **root causes** that unblock the most cascade errors.

### Step 3: Apply fixes

For each fix:
- Make the minimal code change
- Verify the fix is correct (read the file, understand the context)
- Do NOT batch-fix blindly — each fix should be deliberate

### Step 4: Commit

After each meaningful fix or batch of related fixes:
```bash
git add -A && git commit -m "fix: <description of what was fixed>"
```

### Step 5: Re-run diagnostics (once)

Run diagnostics ONE more time to verify the fix reduced errors. Then STOP — do not loop.

### Step 6: Record progress

Update `MIGRATION_CHECKLIST.md` or project memory with:
- Error count before/after
- What was fixed
- What remains

## Common Godot 4 Error Patterns

| Old (Godot 3) | New (Godot 4) |
|---|---|
| `.method()` (dot prefix parent call) | `super.method()` |
| `Log.print()` | `Log.msg()` (avoid shadowing global print) |
| `File.new()` | `FileAccess.open(path, mode)` |
| `Directory.new()` | `DirAccess.open(path)` |
| `node.disconnect(sig, target, method)` | `node.disconnect(sig_name)` |
| `Color.red` | `Color.RED` |
| `onready var x` | `@onready var x` |
| `export(var x)` | `@export var x` |
| `yield(obj, "signal")` | `await obj.signal` |
| `connect("sig", self, "method")` | `signal.connect(method)` |
| `ord(ch)` | `String.unicode_at(index)` |
| `to_json(obj)` | `JSON.stringify(obj)` |
| `HTTPRequest.request(url, hdrs, ssl, meth, body)` | `HTTPRequest.request(url, hdrs, meth, body)` |

## Cascade Error Priority

1. **Autoload scripts** (Log.gd, Util.gd, GlobalRegistry.gd) — fix these first, they block everything
2. **class_name scripts** — scripts that declare `class_name` used by others
3. **BaseCharacter.gd** — the #1 blocker (3918 lines, cascades to Player, Bodyparts, hundreds of others)
4. Everything else — fix in dependency order
