#!/usr/bin/env python3
import json
import os

STATUS_FILE = "/tmp/osrs_status.json"

if os.path.exists(STATUS_FILE):
    with open(STATUS_FILE, "r") as f:
        status = json.load(f)
    print(json.dumps(status))
