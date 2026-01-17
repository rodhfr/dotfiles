#!/usr/bin/env python3

import subprocess
import threading
import sys
import psutil
import gi
import os

gi.require_version("AppIndicator3", "0.1")
from gi.repository import AppIndicator3, Gtk, GLib

APP_ID = "audio-sink-switcher"

for proc in psutil.process_iter(["pid", "name", "cmdline"]):
    cmdline = proc.info.get("cmdline")  # pode ser None
    if cmdline and "audio_tray.py" in " ".join(cmdline) and proc.pid != os.getpid():
        print("Audio Tray Already Running")
        sys.exit()  # Já existe uma instância rodando

print("Audio tray initialize")


def get_sinks():
    out = subprocess.check_output(["pactl", "list", "sinks", "short"], text=True)
    return [line.split("\t")[1] for line in out.splitlines()]


def get_default_sink():
    try:
        out = subprocess.check_output(["pactl", "info"], text=True)
        for line in out.splitlines():
            if line.startswith("Default Sink:"):
                return line.split(":", 1)[1].strip()
    except subprocess.CalledProcessError:
        pass
    return ""  # return empty string instead of None or list


def set_sink(name):
    subprocess.run(["pactl", "set-default-sink", name], check=False)


class TrayApp:
    def __init__(self):
        self.indicator = AppIndicator3.Indicator.new(
            APP_ID,
            "audio-speakers-symbolic",
            AppIndicator3.IndicatorCategory.SYSTEM_SERVICES,
        )

        self.indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)

        self.menu = Gtk.Menu()
        self.indicator.set_menu(self.menu)

        self.refresh_menu()
        self.start_event_listener()

    def refresh_menu(self):
        # Clear menu
        for child in self.menu.get_children():
            self.menu.remove(child)

        sinks = get_sinks()
        current = get_default_sink()

        for sink in sinks:
            label = sink
            if sink == current:
                label = f"✔ {sink}"

            item = Gtk.MenuItem(label=label)
            item.connect("activate", self.on_select, sink)
            item.show()
            self.menu.append(item)

        self.menu.append(Gtk.SeparatorMenuItem())

        quit_item = Gtk.MenuItem(label="Quit")
        quit_item.connect("activate", Gtk.main_quit)
        quit_item.show()
        self.menu.append(quit_item)

        self.menu.show_all()
        return False  # required for GLib.idle_add

    def on_select(self, _, sink):
        set_sink(sink)

    def start_event_listener(self):
        proc = subprocess.Popen(
            ["pactl", "subscribe"],
            stdout=subprocess.PIPE,
            text=True,
        )

        def run():
            if proc.stdout is None:
                return  # safety check
            for line in proc.stdout:
                # Relevant events:
                # "Event 'new' on sink"
                # "Event 'remove' on sink"
                # "Event 'change' on server"
                if "sink" in line.lower() or "server" in line.lower():
                    GLib.idle_add(self.refresh_menu)

        threading.Thread(target=run, daemon=True).start()


def main():
    try:
        TrayApp()
        Gtk.main()
    except Exception as _:
        print("Another instance is already running.")
        exit(0)


if __name__ == "__main__":
    main()
