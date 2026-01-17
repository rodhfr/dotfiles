#!/usr/bin/env python3

from flask import Flask, request, jsonify, render_template, redirect, url_for
import json
import os

app = Flask(__name__)


def clear_term():
    os.system("cls" if os.name == "nt" else "clear")


@app.route("/status_data")
def status_data():
    try:
        with open("/tmp/osrs_status.json") as f:
            data = json.load(f)
    except FileNotFoundError:
        data = {"text": "Loading...", "class": "green"}
    return jsonify(data)

@app.route("/status_data")
def status_data():

@app.route("/")
def home():
    return render_template("index.html")


@app.route("/webhook", methods=["POST"])
def handle_webhook():
    payload_dict = dict(json.loads(str(request.form.get("payload_json"))))
    player_name: str = payload_dict["playerName"]

    payload_title: str = payload_dict["embeds"][0]["title"]
    # payload_title: str -> [runebar] skill_name [start/stop]
    payload_description: str = payload_dict["embeds"][0]["description"]
    # payload_description: str -> stopped_wc

    parsed_payload_title: list = [p.strip("[]") for p in payload_title.split()]
    # parsed_payload_title: list -> ['runebar', 'woodcutting', 'stop']

    if parsed_payload_title[0] == "runebar":
        current_skill = parsed_payload_title[1]

        osrs_json_status = {"player_name": player_name}
        osrs_json_status["current_skill"] = f"{current_skill}_{payload_description}"

        with open("/tmp/osrs_status.json", "w") as f:
            json.dump(osrs_json_status, f)
        os.system("pkill -SIGRTMIN+10 waybar")

        print(osrs_json_status)
    return jsonify({"status": "ok"}), 200


def main():
    port = int(os.environ.get("PORT", 5000))
    app.run(debug=False, host="0.0.0.0", port=port)


if __name__ == "__main__":
    main()
