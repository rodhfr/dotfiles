#!/usr/bin/env python3

import time
import threading
import re
import os
import json
from flask import Flask, request, jsonify


# -----------------------------
# Configuration
# -----------------------------

INACTIVE_SECONDS = 15
IDLE_SECONDS = 600
WAYBAR_SIGNAL = "pkill -SIGRTMIN+10 waybar"


# -----------------------------
# Activity tracking
# -----------------------------


class ActivityTracker:
    def __init__(self):
        self._lock = threading.Lock()
        self._last_active = time.time()
        self._state = "green"

    def mark_active(self):
        with self._lock:
            self._last_active = time.time()

    def update_state(self):
        with self._lock:
            elapsed = time.time() - self._last_active

            if elapsed > IDLE_SECONDS:
                self._state = "idle"
            elif elapsed > INACTIVE_SECONDS:
                self._state = "red"
            else:
                self._state = "green"

    def snapshot(self):
        with self._lock:
            return {
                "text": f"OSRS - Activity {self._state != 'red'}",
                "class": self._state,
                "last_active_seconds_ago": int(time.time() - self._last_active),
            }


# -----------------------------
# Background loop
# -----------------------------


def activity_loop(tracker):
    while True:
        tracker.update_state()
        os.system(WAYBAR_SIGNAL)
        time.sleep(1)


# -----------------------------
# Flask app
# -----------------------------

app = Flask(__name__)
tracker = ActivityTracker()


@app.route("/stats", methods=["GET"])
def stats():
    return jsonify(tracker.snapshot())


@app.route("/webhook", methods=["POST"])
def webhook():
    payload = request.form.get("payload_json")
    if not payload:
        return jsonify({"error": "missing payload_json"}), 400

    try:
        data = json.loads(payload)
    except json.JSONDecodeError:
        return jsonify({"error": "invalid JSON"}), 400

    if data.get("type") == "EXTERNAL_PLUGIN":
        embed = data.get("embeds", [{}])[0]
        # title = embed.get("title")
        # title_parsed = re.split(r",\s*", title)
        # print(title_parsed[1])
        # if title_parsed[1] == "mining":
        #     INACTIVE_SECONDS = 10
        if embed.get("description") == "xp_drop":
            tracker.mark_active()

    return jsonify({"received": True})


# -----------------------------
# Entry point
# -----------------------------


def main():
    threading.Thread(target=activity_loop, args=(tracker,), daemon=True).start()

    app.run(host="0.0.0.0", port=5000, debug=False)


if __name__ == "__main__":
    main()
