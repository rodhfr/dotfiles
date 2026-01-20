#!/usr/bin/env python3

import json
import urllib.request
import sys

URL = "http://127.0.0.1:8080/stats"

# Get skill name and icon from command-line arguments
if len(sys.argv) != 3:
    print(json.dumps({"text": "Usage: script.py <skill> <icon>"}), flush=True)
    sys.exit(1)

skill = sys.argv[1].lower()  # e.g., "hitpoints" or "prayer"
skill_icon = sys.argv[2]  # e.g., "" or ""

# Fetch data from API
try:
    with urllib.request.urlopen(URL, timeout=1) as response:
        data = json.load(response)
except Exception:
    print(json.dumps({"text": ""}), flush=True)
    sys.exit(0)

# Find the skill in data
boosted_active_skill_value = None
skill_level = None

for stat in data:
    if stat.get("stat", "").lower() == skill:
        boosted_active_skill_value = stat.get("boostedLevel")
        skill_level = stat.get("level")
        break

# If skill not found
if boosted_active_skill_value is None or skill_level is None:
    print(json.dumps({"text": "RL: n/a"}), flush=True)
else:
    # Determine state based on thresholds
    thresholds = {
        "upper_nine_tens_value_color": 0.9,
        "upper_three_fours_value_color": 0.75,
        "upper_half_value_color": 0.5,
        "upper_one_four_value_color": 0.25,
        "upper_zero_color": 0,
    }
    state = "idle"

    for state_name, fraction in thresholds.items():
        if boosted_active_skill_value > skill_level * fraction:
            state = state_name
            break

    print(
        json.dumps(
            {
                "text": f"{skill_icon} {boosted_active_skill_value}",
                "class": state,
            }
        ),
        flush=True,
    )
