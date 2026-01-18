#!/usr/bin/env python3

import json
import urllib.request
import sys

URL = "http://127.0.0.1:8080/stats"

skill = "prayer"
skill_icon = ""
upper_good = 30
upper_crit = 12


try:
    with urllib.request.urlopen(URL, timeout=1) as response:
        data = json.load(response)
except Exception:
    print(json.dumps({"text": "RL: offline"}), flush=True)
    sys.exit(0)

boosted_active_skill_value = None

for stat in data:
    if stat.get("stat", "").lower() == skill:
        boosted_active_skill_value = stat.get("boostedLevel")
        break

if boosted_active_skill_value is None:
    print(json.dumps({"text": "RL: n/a"}), flush=True)
else:
    if boosted_active_skill_value >= upper_good:
        state = "good"
    elif boosted_active_skill_value >= upper_crit:
        state = "critical"
    else:
        state = "bad"

    print(
        json.dumps(
            {
                "text": f"{skill_icon} {boosted_active_skill_value}",
                "class": f"{state}",
            }
        ),
        flush=True,
    )
