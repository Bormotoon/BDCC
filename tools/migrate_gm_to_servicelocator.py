#!/usr/bin/env python3
"""Batch migration: GM.X -> ServiceLocator.safe_get_service(&"Name").

Uses safe_get_service() which returns null if service not registered,
semantically equivalent to GM.pc (which could also be null).

Usage:
  # Dry-run (default):
  python3 tools/migrate_gm_to_servicelocator.py

  # Apply changes:
  python3 tools/migrate_gm_to_servicelocator.py --apply

  # Process specific files:
  python3 tools/migrate_gm_to_servicelocator.py --apply --files Game/SomeFile.gd

  # Process a subdirectory:
  python3 tools/migrate_gm_to_servicelocator.py --apply --dir Modules/
"""

import argparse
import os
import re
import sys

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# GM property -> ServiceLocator service name mapping
GM_MAP = {
    "pc": "Player",
    "main": "MainScene",
    "ui": "UI",
    "world": "World",
    "ES": "EventSystem",
    "QS": "QuestSystem",
    "CS": "ChildSystem",
    "GES": "GameExtenderSystem",
    "PROFILE": "Profiler",
}

# Blacklist: files/dirs that should NOT be modified
SKIP_PATTERNS = [
    "Game/GM.gd",
    "Core/ServiceLocator.gd",
    "addons/",
    ".godot/",
]


def should_skip(filepath):
    relpath = os.path.relpath(filepath, PROJECT_ROOT)
    for pat in SKIP_PATTERNS:
        if pat in relpath:
            return True
    return False


def replace_in_file(filepath, dry_run=True):
    """Replace GM.X with ServiceLocator.safe_get_service() in a single .gd file.

    Returns number of changed lines, or None if no changes.
    """
    if should_skip(filepath):
        return None

    relpath = os.path.relpath(filepath, PROJECT_ROOT)
    with open(filepath) as f:
        original = f.read()

    if 'GM.' not in original:
        return None

    content = original
    total_count = 0
    changes = []

    for prop, svc in GM_MAP.items():
        target = f'GM.{prop}'
        replacement = f'ServiceLocator.safe_get_service(&"{svc}")'

        # Match GM.prop as a whole word, but not as part of a larger identifier
        pattern = re.compile(r'(?<!\w)' + re.escape(target) + r'(?!\w)')
        new_content, count = pattern.subn(replacement, content)
        if count > 0:
            changes.append(f"  [{prop}] {count} replacement(s)")
            total_count += count
            content = new_content

    if total_count == 0:
        return None

    # Build preview of first 10 changes
    orig_lines = original.split('\n')
    new_lines = content.split('\n')
    preview_lines = []
    for i, (old_l, new_l) in enumerate(zip(orig_lines, new_lines)):
        if old_l != new_l:
            preview_lines.append((i + 1, old_l.strip(), new_l.strip()))

    if dry_run:
        print(f"\n[DRY-RUN] {relpath}")
        for c in changes:
            print(c)
        if preview_lines:
            for lineno, old, new in preview_lines[:8]:
                print(f"  L{lineno}: -{old}")
                print(f"           +{new}")
            if len(preview_lines) > 8:
                print(f"  ... and {len(preview_lines) - 8} more changes")
        return len(preview_lines)
    else:
        # Write original to .bak file if not already backed up
        bak_path = filepath + ".bak"
        if not os.path.exists(bak_path):
            os.rename(filepath, bak_path)
            with open(filepath, 'w') as f:
                f.write(content)
        else:
            # Backup already exists, just overwrite
            with open(filepath, 'w') as f:
                f.write(content)

        print(f"[MODIFIED] {relpath} ({total_count} replacements)")
        for c in changes:
            print(c)
        return len(preview_lines)


def find_gd_files(root_dir):
    """Find all .gd files in the given directory."""
    gd_files = []
    for root, dirs, files in os.walk(root_dir):
        # Skip hidden directories
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        if '/addons/' in root or '\\addons\\' in root:
            continue
        for f in files:
            if f.endswith('.gd'):
                gd_files.append(os.path.join(root, f))
    return gd_files


def main():
    parser = argparse.ArgumentParser(
        description="Migrate GM.X -> ServiceLocator.safe_get_service() in GDScript files"
    )
    parser.add_argument('--apply', action='store_true',
                        help='Apply changes (default: dry-run)')
    parser.add_argument('--files', nargs='+',
                        help='Process specific files (relative to project root)')
    parser.add_argument('--dir',
                        help='Process a specific subdirectory (relative to project root)')
    args = parser.parse_args()

    if args.files:
        gd_files = [os.path.join(PROJECT_ROOT, f) for f in args.files]
    elif args.dir:
        gd_files = find_gd_files(os.path.join(PROJECT_ROOT, args.dir))
    else:
        gd_files = find_gd_files(PROJECT_ROOT)

    # Filter to only files with GM. that aren't skipped
    target_files = []
    for fp in gd_files:
        if should_skip(fp):
            continue
        try:
            with open(fp) as f:
                if 'GM.' in f.read():
                    target_files.append(fp)
        except (IOError, UnicodeDecodeError):
            continue

    mode = "DRY-RUN" if not args.apply else "APPLY"
    print(f"Mode: {mode}")
    print(f"Files with GM.*: {len(target_files)}")

    total_changed = 0
    total_modified_files = 0

    for fp in sorted(target_files):
        result = replace_in_file(fp, dry_run=not args.apply)
        if result is not None:
            total_changed += result
            total_modified_files += 1

    print(f"\n{'=' * 50}")
    print(f"Summary ({mode}):")
    print(f"  Files modified: {total_modified_files}")
    print(f"  Lines changed:  {total_changed}")
    if not args.apply:
        print(f"\nRun with --apply to apply changes.")
    print(f"{'=' * 50}")


if __name__ == '__main__':
    main()
