#!/usr/bin/env python3
"""
catchup.py — batch-process Claude Code transcripts for session summaries.

Scans every .jsonl transcript under ~/.claude/projects/, finds ones that
contain <!-- BEGIN_SESSION_SUMMARY --> markers, and feeds them to
extract-session-summary.sh. Skips already-processed sessions.

Usage:
    python3 catchup.py [--dry-run] [--project <fragment>]
"""

import argparse
import glob
import json
import os
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
EXTRACT_SCRIPT = SCRIPT_DIR.parent / "hooks" / "extract-session-summary.sh"
LEARNINGS_REPO = Path(os.environ.get("LEARNINGS_REPO", Path.home() / "code/learnings"))
TRANSCRIPTS_DIR = Path(os.environ.get("CLAUDE_TRANSCRIPTS_DIR", Path.home() / ".claude/projects"))


def get_processed_sessions(learnings_repo: Path) -> set:
    """Return set of session IDs already in the learnings repo."""
    processed = set()
    sessions_dir = learnings_repo / "sessions"
    if not sessions_dir.exists():
        return processed
    for f in sessions_dir.rglob("*.md"):
        # Filename: YYYY-MM-DD-<session_id>.md
        name = f.stem
        # Strip leading date prefix (10 chars: YYYY-MM-DD-)
        if len(name) > 11 and name[10] == "-":
            processed.add(name[11:])
        else:
            processed.add(name)
    return processed


def has_summary_marker(transcript_path: Path) -> bool:
    """Check for actual sentinel in assistant text content only.
    Avoids false positives from tool-use content (e.g. the extract script itself)."""
    marker = "<!-- BEGIN_SESSION_SUMMARY -->"
    try:
        with open(transcript_path) as f:
            for line in f:
                try:
                    msg = json.loads(line)
                    if msg.get("type") != "assistant":
                        continue
                    for block in msg.get("message", {}).get("content", []):
                        if isinstance(block, dict) and block.get("type") == "text":
                            if marker in block.get("text", ""):
                                return True
                except json.JSONDecodeError:
                    continue
    except Exception:
        pass
    return False


def get_cwd_from_transcript(transcript_path: Path) -> str:
    """Extract cwd from first message that has it."""
    try:
        with open(transcript_path) as f:
            for line in f:
                try:
                    msg = json.loads(line)
                    if cwd := msg.get("cwd"):
                        return cwd
                except json.JSONDecodeError:
                    continue
    except Exception:
        pass
    return str(Path.home())


def extract_session(session_id: str, transcript_path: Path, cwd: str) -> bool:
    """Call extract-session-summary.sh with the session payload."""
    payload = json.dumps({
        "session_id": session_id,
        "transcript_path": str(transcript_path),
        "cwd": cwd,
        "reason": "catchup",
    })
    try:
        result = subprocess.run(
            ["bash", str(EXTRACT_SCRIPT)],
            input=payload,
            text=True,
            capture_output=True,
            timeout=30,
        )
        return result.returncode == 0
    except Exception as e:
        print(f"  Error: {e}", file=sys.stderr)
        return False


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="Print without extracting")
    parser.add_argument("--project", default="", help="Filter by project dir fragment")
    args = parser.parse_args()

    if not EXTRACT_SCRIPT.exists():
        print(f"Error: extract script not found at {EXTRACT_SCRIPT}", file=sys.stderr)
        sys.exit(1)

    if not (LEARNINGS_REPO / ".git").exists():
        print(f"Error: learnings repo not found at {LEARNINGS_REPO}", file=sys.stderr)
        sys.exit(1)

    processed = get_processed_sessions(LEARNINGS_REPO)
    print(f"Already processed: {len(processed)} sessions", file=sys.stderr)

    transcripts = sorted(TRANSCRIPTS_DIR.rglob("*.jsonl"))

    counts = {"found": 0, "no_markers": 0, "already_done": 0, "extracted": 0, "errors": 0}

    for transcript in transcripts:
        proj_slug = transcript.parent.name

        if args.project and args.project not in proj_slug:
            continue

        counts["found"] += 1
        session_id = transcript.stem

        if session_id in processed:
            counts["already_done"] += 1
            continue

        if not has_summary_marker(transcript):
            counts["no_markers"] += 1
            continue

        cwd = get_cwd_from_transcript(transcript)

        if args.dry_run:
            print(f"WOULD PROCESS: {session_id} ({proj_slug}, cwd={cwd})")
            counts["extracted"] += 1
            continue

        if extract_session(session_id, transcript, cwd):
            print(f"Extracted: {session_id} ({proj_slug})", file=sys.stderr)
            counts["extracted"] += 1
        else:
            print(f"Error: {session_id}", file=sys.stderr)
            counts["errors"] += 1

    print("", file=sys.stderr)
    print("=== Catch-up complete ===", file=sys.stderr)
    print(f"  Scanned:           {counts['found']}", file=sys.stderr)
    print(f"  No markers (skip): {counts['no_markers']}", file=sys.stderr)
    print(f"  Already processed: {counts['already_done']}", file=sys.stderr)
    print(f"  Extracted:         {counts['extracted']}", file=sys.stderr)
    print(f"  Errors:            {counts['errors']}", file=sys.stderr)

    if counts["extracted"] > 0 and not args.dry_run:
        print("", file=sys.stderr)
        print("Next: run rollup generator in the learnings repo to update patterns.", file=sys.stderr)


if __name__ == "__main__":
    main()
