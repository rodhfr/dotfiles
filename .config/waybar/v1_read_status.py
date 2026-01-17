#!/usr/bin/env python3
import json
import os
import time
import logging

STATUS_FILE = "/tmp/osrs_status.json"
IDLE_THRESHOLD = 10 * 60  # 10 minutos
logging.basicConfig(level=logging.WARNING)


def main():
    now = time.time()
    status = {"text": "OSRS - Activity: False | Skill: ", "class": "idle"}

    if os.path.exists(STATUS_FILE):
        try:
            with open(STATUS_FILE, "r") as f:
                data = json.load(f)

            text = data.get("text", "")
            last_active_time = data.get("last_active_time", now)

            # Calcula se está idle
            if now - last_active_time > IDLE_THRESHOLD:
                status_class = "idle"
                status_text = "OSRS - Activity: False | Skill: "
            elif "Activity: True" in text:
                status_class = "green"
                status_text = text
            else:
                status_class = "red"
                status_text = text

            status["text"] = status_text
            status["class"] = status_class

        except Exception as e:
            logging.error(f"Erro lendo {STATUS_FILE}: {e}")

    print(json.dumps(status))


if __name__ == "__main__":
    main()
