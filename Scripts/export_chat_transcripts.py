#!/usr/bin/env python3
"""
Export Claude Code chat transcripts to readable Markdown.

Reads JSONL conversation files from ~/.claude/projects/ and converts them
to Markdown files in Docs/ChatTranscripts/.

Usage:
    python3 Scripts/export_chat_transcripts.py                # Export all sessions
    python3 Scripts/export_chat_transcripts.py --latest 3     # Export 3 most recent
    python3 Scripts/export_chat_transcripts.py --session ID   # Export specific session
    python3 Scripts/export_chat_transcripts.py --list         # List available sessions
"""

import json
import os
import sys
import argparse
from datetime import datetime
from pathlib import Path

# Project-specific transcript directory
PROJECT_DIR = "-Users-tboliveira-Projetos-StarshipLander"
TRANSCRIPTS_PATH = Path.home() / ".claude" / "projects" / PROJECT_DIR
OUTPUT_DIR = Path(__file__).resolve().parent.parent / "Docs" / "ChatTranscripts"


def load_session(filepath: Path) -> list[dict]:
    """Load all entries from a JSONL session file."""
    entries = []
    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entries.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    return entries


def get_session_info(entries: list[dict]) -> dict:
    """Extract metadata from session entries."""
    info = {
        "session_id": None,
        "timestamp_start": None,
        "timestamp_end": None,
        "version": None,
        "branch": None,
        "user_messages": 0,
        "assistant_messages": 0,
        "tool_calls": 0,
        "first_user_message": "",
    }

    for entry in entries:
        if entry.get("sessionId") and not info["session_id"]:
            info["session_id"] = entry["sessionId"]
        if entry.get("version") and not info["version"]:
            info["version"] = entry["version"]
        if entry.get("gitBranch") and not info["branch"]:
            info["branch"] = entry["gitBranch"]

        ts = entry.get("timestamp")
        if ts:
            if not info["timestamp_start"]:
                info["timestamp_start"] = ts
            info["timestamp_end"] = ts

        msg_type = entry.get("type")
        if msg_type == "user":
            info["user_messages"] += 1
            content = entry.get("message", {}).get("content", "")
            if isinstance(content, str) and content and not info["first_user_message"]:
                info["first_user_message"] = content[:100]
            elif isinstance(content, list):
                for block in content:
                    if block.get("type") == "tool_result":
                        info["tool_calls"] += 1
                    elif block.get("type") == "text" and not info["first_user_message"]:
                        info["first_user_message"] = block.get("text", "")[:100]
        elif msg_type == "assistant":
            info["assistant_messages"] += 1

    return info


def extract_text_content(content) -> str:
    """Extract readable text from message content."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for block in content:
            btype = block.get("type", "")
            if btype == "text":
                text = block.get("text", "")
                if text.strip():
                    parts.append(text)
            elif btype == "tool_use":
                tool_name = block.get("name", "unknown")
                tool_input = block.get("input", {})
                summary = format_tool_call(tool_name, tool_input)
                parts.append(summary)
            elif btype == "tool_result":
                # Skip tool results in output (they're verbose)
                content_inner = block.get("content", "")
                if isinstance(content_inner, str) and len(content_inner) < 200:
                    parts.append(f"> Tool result: {content_inner}")
                elif isinstance(content_inner, list):
                    for inner in content_inner:
                        if inner.get("type") == "text":
                            text = inner.get("text", "")
                            if len(text) < 200:
                                parts.append(f"> Tool result: {text}")
                            else:
                                parts.append(f"> Tool result: ({len(text)} chars)")
                else:
                    parts.append("> Tool result: (output omitted)")
        return "\n\n".join(parts)
    return ""


def format_tool_call(name: str, input_data: dict) -> str:
    """Format a tool call into a readable summary."""
    if name == "Read":
        path = input_data.get("file_path", "?")
        return f"*Read file: `{os.path.basename(path)}`*"
    elif name == "Write":
        path = input_data.get("file_path", "?")
        return f"*Write file: `{os.path.basename(path)}`*"
    elif name == "Edit":
        path = input_data.get("file_path", "?")
        return f"*Edit file: `{os.path.basename(path)}`*"
    elif name == "Bash":
        cmd = input_data.get("command", "?")
        if len(cmd) > 120:
            cmd = cmd[:120] + "..."
        return f"*Run: `{cmd}`*"
    elif name == "Glob":
        pattern = input_data.get("pattern", "?")
        return f"*Search files: `{pattern}`*"
    elif name == "Grep":
        pattern = input_data.get("pattern", "?")
        return f"*Search content: `{pattern}`*"
    elif name == "Task":
        desc = input_data.get("description", "?")
        return f"*Task: {desc}*"
    elif name == "TodoWrite":
        todos = input_data.get("todos", [])
        items = [f"  - {'[x]' if t.get('status') == 'completed' else '[ ]'} {t.get('content', '?')}" for t in todos]
        return f"*Update todos:*\n" + "\n".join(items)
    elif name == "WebFetch":
        url = input_data.get("url", "?")
        return f"*Fetch: {url}*"
    elif name == "WebSearch":
        query = input_data.get("query", "?")
        return f"*Search web: {query}*"
    else:
        return f"*Tool: {name}*"


def format_timestamp(ts_str: str) -> str:
    """Format ISO timestamp to readable form."""
    try:
        dt = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
        return dt.strftime("%Y-%m-%d %H:%M:%S UTC")
    except (ValueError, AttributeError):
        return ts_str or "Unknown"


def export_session(filepath: Path, output_dir: Path, verbose: bool = False) -> Path:
    """Export a single session JSONL to Markdown."""
    entries = load_session(filepath)
    if not entries:
        return None

    info = get_session_info(entries)
    session_id = info["session_id"] or filepath.stem

    # Generate output filename with date prefix
    date_str = ""
    if info["timestamp_start"]:
        try:
            dt = datetime.fromisoformat(info["timestamp_start"].replace("Z", "+00:00"))
            date_str = dt.strftime("%Y-%m-%d_")
        except ValueError:
            pass

    short_id = session_id[:8]
    output_file = output_dir / f"{date_str}{short_id}.md"

    lines = []
    lines.append(f"# Chat Transcript: {short_id}")
    lines.append("")
    lines.append(f"**Session ID:** `{session_id}`")
    lines.append(f"**Started:** {format_timestamp(info['timestamp_start'])}")
    lines.append(f"**Ended:** {format_timestamp(info['timestamp_end'])}")
    if info["version"]:
        lines.append(f"**Claude Code Version:** {info['version']}")
    if info["branch"]:
        lines.append(f"**Git Branch:** {info['branch']}")
    lines.append(f"**Messages:** {info['user_messages']} user, {info['assistant_messages']} assistant")
    lines.append("")
    lines.append("---")
    lines.append("")

    msg_num = 0
    for entry in entries:
        entry_type = entry.get("type")

        if entry_type == "user":
            content = entry.get("message", {}).get("content", "")
            text = extract_text_content(content)
            if not text.strip():
                continue
            # Skip pure tool_result entries (they clutter the transcript)
            if isinstance(content, list) and all(b.get("type") == "tool_result" for b in content):
                continue
            msg_num += 1
            ts = format_timestamp(entry.get("timestamp", ""))
            lines.append(f"## User ({ts})")
            lines.append("")
            lines.append(text)
            lines.append("")

        elif entry_type == "assistant":
            msg = entry.get("message", {})
            content = msg.get("content", [])
            text = extract_text_content(content)
            if not text.strip():
                continue
            # Skip thinking-only blocks
            if isinstance(content, list) and all(b.get("type") == "thinking" for b in content):
                continue

            error = entry.get("error")
            if error:
                lines.append(f"## Assistant (Error: {error})")
            else:
                lines.append("## Assistant")
            lines.append("")
            lines.append(text)
            lines.append("")

    output_dir.mkdir(parents=True, exist_ok=True)
    output_file.write_text("\n".join(lines), encoding="utf-8")

    if verbose:
        print(f"  Exported: {output_file.name} ({info['user_messages']} user msgs, {info['assistant_messages']} assistant msgs)")

    return output_file


def list_sessions():
    """List all available sessions with metadata."""
    if not TRANSCRIPTS_PATH.exists():
        print(f"No transcripts found at {TRANSCRIPTS_PATH}")
        return

    files = sorted(TRANSCRIPTS_PATH.glob("*.jsonl"), key=lambda f: f.stat().st_mtime, reverse=True)
    if not files:
        print("No JSONL files found.")
        return

    print(f"Found {len(files)} session(s) in {TRANSCRIPTS_PATH}\n")
    print(f"{'#':<4} {'Session ID':<40} {'Date':<22} {'User Msgs':<10} {'First Message'}")
    print("-" * 120)

    for i, f in enumerate(files, 1):
        # Skip agent subprocesses
        if f.stem.startswith("agent-"):
            continue
        entries = load_session(f)
        info = get_session_info(entries)
        date = format_timestamp(info["timestamp_start"])[:19] if info["timestamp_start"] else "Unknown"
        first = info["first_user_message"][:50]
        print(f"{i:<4} {(info['session_id'] or f.stem):<40} {date:<22} {info['user_messages']:<10} {first}")


def main():
    parser = argparse.ArgumentParser(description="Export Claude Code chat transcripts to Markdown")
    parser.add_argument("--latest", type=int, metavar="N", help="Export N most recent sessions")
    parser.add_argument("--session", type=str, metavar="ID", help="Export specific session by ID (partial match)")
    parser.add_argument("--list", action="store_true", help="List available sessions")
    parser.add_argument("--all", action="store_true", help="Export all sessions")
    parser.add_argument("--output", type=str, metavar="DIR", help="Output directory (default: Docs/ChatTranscripts/)")
    args = parser.parse_args()

    if args.list:
        list_sessions()
        return

    output_dir = Path(args.output) if args.output else OUTPUT_DIR

    if not TRANSCRIPTS_PATH.exists():
        print(f"Error: No transcripts directory found at {TRANSCRIPTS_PATH}")
        sys.exit(1)

    # Collect session files (skip agent subprocesses)
    all_files = sorted(
        [f for f in TRANSCRIPTS_PATH.glob("*.jsonl") if not f.stem.startswith("agent-")],
        key=lambda f: f.stat().st_mtime,
        reverse=True,
    )

    if not all_files:
        print("No session files found.")
        sys.exit(1)

    if args.session:
        files = [f for f in all_files if args.session in f.stem]
        if not files:
            print(f"No session matching '{args.session}' found.")
            sys.exit(1)
    elif args.latest:
        files = all_files[: args.latest]
    elif args.all:
        files = all_files
    else:
        # Default: export latest 5
        files = all_files[:5]
        print(f"Exporting {len(files)} most recent sessions (use --all for everything, --list to browse)\n")

    exported = 0
    for f in files:
        result = export_session(f, output_dir, verbose=True)
        if result:
            exported += 1

    print(f"\nExported {exported} transcript(s) to {output_dir}/")


if __name__ == "__main__":
    main()
