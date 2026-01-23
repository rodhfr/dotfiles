#!/usr/bin/env bash

nohup python activity.py >/dev/null 2>&1 &
curl -sf http://127.0.0.1:5000/stats || echo '{"text":"OSRS - Activity: ?","class":"idle"}'
