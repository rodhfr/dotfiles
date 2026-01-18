#!/usr/bin/env python3

import json
import urllib.request
import sys

URL = "http://127.0.0.1:8080/stats"

skill = "hitpoints"
skill_icon = ""
upper_good = 60
upper_crit = 30

try:
    with urllib.request.urlopen(URL, timeout=1) as response:
        data = json.load(response)
except Exception:
    print(json.dumps({"text": "RL: offline"}), flush=True)
    sys.exit(0)

boosted_active_skill_value = None
skill_level = None

for stat in data:
    if stat.get("stat", "").lower() == skill:
        boosted_active_skill_value = stat.get("boostedLevel")
        skill_level = stat.get("level")
        break

if boosted_active_skill_value is None or skill_level is None:
    print(json.dumps({"text": "RL: n/a"}), flush=True)
else:
    nine_tens_value_color = skill_level / 0.90
    three_fours_value_color = skill_level / 0.75
    half_value_color = skill_level / 0.5
    one_four_value_color = skill_level / 0.25
    if boosted_active_skill_value >= nine_tens_value_color:
        state = "upper_nine_tens_value_color"
    elif boosted_active_skill_value >= three_fours_value_color:
        state = "upper_three_fours_value_color"
    elif boosted_active_skill_value >= half_value_color:
        state = "upper_half_value_color"
    elif boosted_active_skill_value >= one_four_value_color:
        state = "upper_one_four_value_color"
    else:
        state = "upper_zero_color"

    print(
        json.dumps(
            {
                "text": f"{skill_icon} {boosted_active_skill_value} ",
                "class": f"{state}",
            }
        ),
        flush=True,
    )
