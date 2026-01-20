#!/usr/bin/env python3

from flask_socketio import SocketIO
from flask import Flask, request, jsonify, render_template, redirect, url_for
import threading
import time
import logging
import json
import os

app = Flask(__name__)
app.config["aIJDaidjsaiodjsa"] = "sakdjasdasldjasdk"
socketio = SocketIO(app)

log = logging.getLogger("werkzeug")
log.setLevel(logging.ERROR)


def clear_term():
    os.system("cls" if os.name == "nt" else "clear")


class Counter:
    value = 0
    activity_status = True
    last_active_time = time.time()


def activity_monitor():
    maxTimeActivityFalse = 15
    while True:
        now = time.time()
        elapsed_fn = now - Counter.last_active_time
        if elapsed_fn > 600:
            if Counter.activity_status:
                # print("Player became idle!")
                Counter.activity_status = False
            css_class = "idle"
        elif elapsed_fn > maxTimeActivityFalse:
            if Counter.activity_status:
                # print("Player became inactive!")
                Counter.activity_status = False
            css_class = "red"
        else:
            Counter.activity_status = True
            css_class = "green"
        text = f"OSRS - Activity: {Counter.activity_status}"
        text = {"text": text, "class": css_class}
        print(json.dumps(text), flush=True)
        with open("/tmp/osrs_status.json", "w") as f:
            json.dump(text, f)
        os.system("pkill -SIGRTMIN+10 waybar")
        time.sleep(1)


threading.Thread(target=activity_monitor, daemon=True).start()


@app.route("/status_data")
def status_data():
    try:
        with open("/tmp/osrs_status.json") as f:
            data = json.load(f)
    except FileNotFoundError:
        data = {"text": "Loading...", "class": "green"}
    return jsonify(data)


@app.route("/status")
def status():
    return render_template("index.html")


@app.route("/")
def home():
    return redirect(url_for("status"))


@app.route("/about")
def about():
    return "<h1>About us</h1>"


@app.route("/webhook", methods=["POST"])
def handle_webhook():
    payload_json = request.form.get("payload_json")
    # print(payload_json)

    if not payload_json:
        return jsonify({"error": "No payload_json provided"}), 400

    try:
        data = json.loads(payload_json)
    except json.JSONDecodeError:
        return jsonify({"error": "Invalid JSON"}), 400

    if data["type"] == "EXTERNAL_PLUGIN":
        data_embed = data["embeds"][0]
        embed_description = data_embed["description"]
        # print(embed_description)
        is_player_active = embed_description == "xp_drop"
        if is_player_active:
            Counter.last_active_time = time.time()
        # print("is_player_active:", Counter.activity_status)

        Counter.value += 1
        if Counter.value > 1000:
            Counter.value = 0
    return jsonify({"received": data}), 200


def main():
    port = int(os.environ.get("PORT", 5000))
    app.run(debug=False, host="0.0.0.0", port=port)


if __name__ == "__main__":
    main()
