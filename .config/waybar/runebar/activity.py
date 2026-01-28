#!/usr/bin/env python3

import time, threading, re, os, json
from flask import Flask, request, jsonify

DEFAULT_INACTIVE_SECONDS = 15
IDLE_SECONDS = 600
WAYBAR_SIGNAL = "pkill -SIGRTMIN+10 waybar"
CONFIG_FILE = os.path.join(os.path.dirname(__file__), "skill_config.json")

def load_skill_config():
    try:
        with open(CONFIG_FILE, "r") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {"default": DEFAULT_INACTIVE_SECONDS}


class ActivityTracker:
    def __init__(self, skill_timeouts):
        self._lock = threading.Lock()
        self._last_active = time.time()
        self._state = "green"
        self._skill_timeouts = skill_timeouts
        self._current_skill = None
        self._default_timeout = skill_timeouts.get("default", DEFAULT_INACTIVE_SECONDS)
        self._inactive_seconds = self._default_timeout

    def set_skill(self, skill_name):
        with self._lock:
            self._current_skill = skill_name
            self._inactive_seconds = self._skill_timeouts.get(skill_name, self._default_timeout)

    def mark_active(self):
        with self._lock:
            self._last_active = time.time()
            self._state = "green"

    def mark_inactive(self):
        with self._lock:
            self._last_active = time.time() - self._inactive_seconds - 1
            self._state = "red"

    def update_state(self):
        with self._lock:
            elapsed = time.time() - self._last_active
            if elapsed > IDLE_SECONDS:
                self._state = "idle"
            elif elapsed > self._inactive_seconds:
                self._state = "red"
            else:
                self._state = "green"

    def snapshot(self):
        with self._lock:
            return {
                "text": f"OSRS - Activity {self._state != 'red'}",
                "class": self._state,
                "last_active_seconds_ago": int(time.time() - self._last_active),
                "current_skill": self._current_skill,
                "inactive_timeout": self._inactive_seconds,
            }


def activity_loop(tracker):
    while True:
        tracker.update_state()
        os.system(WAYBAR_SIGNAL)
        time.sleep(1)


app = Flask(__name__)
skill_config = load_skill_config()
tracker = ActivityTracker(skill_config)

@app.route("/stats")
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
        description = embed.get("description")
        if description in ("xp_drop", "xp_start"):
            title = embed.get("title")
            if title:
                title_parsed = re.split(r",\s*", title)
                if len(title_parsed) > 1:
                    tracker.set_skill(title_parsed[1].lower())
            tracker.mark_active()
        elif description == "xp_stop":
            tracker.mark_inactive()
    return jsonify({"received": True})


if __name__ == "__main__":
    threading.Thread(target=activity_loop, args=(tracker,), daemon=True).start()
    app.run(host="0.0.0.0", port=5000, debug=False)
