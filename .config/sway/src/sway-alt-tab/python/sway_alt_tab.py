#!/usr/bin/env python3
import subprocess
import json
import threading
import time
import os
import sys

HISTORY_FILE = os.path.expanduser("~/.sway_focus_history")
HISTORY_LIMIT = 5
history = []

def save_history():
    with open(HISTORY_FILE, "w") as f:
        for win_id in history:
            f.write(f"{win_id}\n")

def load_history():
    global history
    if os.path.exists(HISTORY_FILE):
        with open(HISTORY_FILE) as f:
            history = [line.strip() for line in f if line.strip()]

def subscribe_focus():
    proc = subprocess.Popen(
        ["swaymsg", "-t", "subscribe", "-m", '[ "window" ]'],
        stdout=subprocess.PIPE,
        text=True
    )
    for line in proc.stdout:
        try:
            event = json.loads(line)
            win_id = str(event["container"]["id"])
            if history and history[0] == win_id:
                continue
            if win_id in history:
                history.remove(win_id)
            history.insert(0, win_id)
            history[:] = history[:HISTORY_LIMIT]
            save_history()
        except Exception:
            continue

def focus_last_window():
    # pega a janela atual
    result = subprocess.run(["swaymsg", "-t", "get_tree"], capture_output=True, text=True)
    try:
        tree = json.loads(result.stdout)
        current = None
        for node in tree["nodes"]:
            # Busca recursiva para encontrar janela focada
            stack = [node]
            while stack:
                n = stack.pop()
                if n.get("focused"):
                    current = str(n["id"])
                    break
                stack.extend(n.get("nodes", []) + n.get("floating_nodes", []))
            if current:
                break
    except Exception:
        print("Não consegui detectar a janela atual")
        return

    for win_id in history:
        if win_id != current:
            subprocess.run(["swaymsg", f"[con_id={win_id}] focus"])
            return
    print("Nenhuma janela anterior encontrada.")

if __name__ == "__main__":
    load_history()

    if len(sys.argv) > 1 and sys.argv[1] == "daemon":
        print("Iniciando daemon de histórico de foco...")
        subscribe_focus()  # fica rodando
    else:
        focus_last_window()

