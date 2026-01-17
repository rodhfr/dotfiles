#!/usr/bin/env python#!/usr/bin/env python3
import json
import os
import time

STATUS_FILE = "/tmp/osrs_status.json"
IDLE_THRESHOLD = 10 * 60  # 10 minutos

# Mapeamento skill -> emoji (substitui o nome da skill)
SKILL_EMOJI = {
    "woodcutting": "🪓",
    "combat": "⚔️",
    "mining": "⛏️",
    "fishing": "🎣",
    "crafting": "🛠️",
}


def main():
    now = time.time()
    status = {"text": "OSRS - Activity: False | Skill: ", "class": "idle"}

    if os.path.exists(STATUS_FILE):
        try:
            with open(STATUS_FILE, "r") as f:
                data = json.load(f)

            text = data.get("text", "")
            last_active_time = data.get("last_active_time", now)

            skill_name = text.split("Skill:")[-1].strip()

            # Calcula idle (>10min)
            if skill_name == "" and now - last_active_time > IDLE_THRESHOLD:
                status_class = "idle"
                status_text = "OSRS - Activity: False | Skill: "
            elif "Activity: True" in text:
                status_class = "green"
                # Substitui o skill_name pelo emoji
                emoji = SKILL_EMOJI.get(skill_name, "")
                status_text = f"OSRS - Activity: True | Skill: {emoji}"
            else:
                status_class = "red"
                emoji = SKILL_EMOJI.get(skill_name, "")
                status_text = f"OSRS - Activity: False | Skill: {emoji}"

            status["text"] = status_text
            status["class"] = status_class

        except Exception:
            status["text"] = "OSRS - Loading..."
            status["class"] = "idle"

    print(json.dumps(status))


if __name__ == "__main__":
    main()
