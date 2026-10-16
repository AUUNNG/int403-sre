#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path

def get_repo_root():
    return Path(__file__).resolve().parent.parent

def run_linter(repo_root):
    lint_script = repo_root / "scripts" / "lint-forms.sh"
    res = subprocess.run(
        ["bash", str(lint_script)],
        cwd=str(repo_root),
        capture_output=True,
        text=True
    )
    return res.returncode, res.stdout + res.stderr

def main():
    try:
        input_data = json.load(sys.stdin)
    except Exception:
        input_data = {}

    repo_root = get_repo_root()
    event = None
    if len(sys.argv) > 2 and sys.argv[1] == "--event":
        event = sys.argv[2]

    # PreToolUse handler
    if event == "PreToolUse":
        tool_call = input_data.get("toolCall", {})
        tool_name = tool_call.get("name", "")
        tool_args = tool_call.get("args", {})
        
        if tool_name == "run_command":
            cmd = tool_args.get("CommandLine", "")
            if "git commit" in cmd:
                import re
                if re.search(r'[\U0001F300-\U0001FAFF\u2600-\u260F\u2612-\u26FF\u2700-\u27BF]', cmd):
                    json.dump({
                        "decision": "deny",
                        "reason": "Agent hook blocked git commit: commit message contains emoji. Zero emoji rule violated."
                    }, sys.stdout)
                    return
            if "git commit" in cmd or "git add" in cmd:
                code, output = run_linter(repo_root)
                if code != 0:
                    json.dump({
                        "decision": "deny",
                        "reason": f"Agent hook blocked command because compliance linter failed:\n{output}"
                    }, sys.stdout)
                    return
        json.dump({"decision": "allow"}, sys.stdout)
        return

    # Stop handler
    if event == "Stop":
        termination_reason = input_data.get("terminationReason", "")
        # Only check on normal completion
        if termination_reason in ("NO_TOOL_CALL", ""):
            code, output = run_linter(repo_root)
            if code != 0:
                json.dump({
                    "decision": "continue",
                    "reason": f"Agent hook blocked stop: forms linter detected violations that must be fixed:\n{output}"
                }, sys.stdout)
                return
        json.dump({"decision": "allow"}, sys.stdout)
        return

    # Default fallback
    json.dump({"decision": "allow"}, sys.stdout)

if __name__ == "__main__":
    main()
