#!/usr/bin/env python3

import requests
import time
import json
import os


def clear_term():
    os.system("cls" if os.name == "nt" else "clear")


def get_status():
    while True:
        clear_term()

        r = requests.get("http://localhost:8080/stats")
        if r.status_code == 200:
            d = r.json()
            print(d)
            prayer_boosted_lst = [
                x["boostedLevel"] for x in d if x["stat"].lower() == "prayer"
            ]
            prayer_boosted_str = prayer_boosted_lst[0] if prayer_boosted_lst else None
            hitpoints_boosted_lst = [
                x["boostedLevel"] for x in d if x["stat"].lower() == "hitpoints"
            ]
            hitpoints_boosted_str = (
                hitpoints_boosted_lst[0] if hitpoints_boosted_lst else None
            )

            status = {
                "text": f"HP: {hitpoints_boosted_str} | PRAY: {prayer_boosted_str}"
            }
            print(status)

            with open("/tmp/osrs_status_http.json", "w") as f:
                json.dump(status, f)

        time.sleep(1)
        os.system("pkill -SIGRTMIN+11 waybar")


def main():
    get_status()


if __name__ == "__main__":
    main()
