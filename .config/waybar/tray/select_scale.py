#!/usr/bin/env python3

import os
import subprocess
import gi
import sys
import psutil

gi.require_version("AppIndicator3", "0.1")
from gi.repository import AppIndicator3, Gtk, GLib

APP_ID = "sway-scale-switcher"

# The two scale options
SCALES = [
    ("Desktop Mode 󰍹", "1", "1920x1080@74.973Hz"),
    ("Mobile Mode ", "1.5", "1920x1080@59.940Hz"),
]
OUTPUT = "HDMI-A-1"


for proc in psutil.process_iter(["pid", "name", "cmdline"]):
    cmdline = proc.info.get("cmdline")  # pode ser None
    if cmdline and "select_scale.py" in " ".join(cmdline) and proc.pid != os.getpid():
        print("Select Scale Already Running")
        sys.exit()  # Já existe uma instância rodando

print("Audio tray initialize")


def get_current_scale():
    """Get the current scale of the output."""
    try:
        out = subprocess.check_output(["swaymsg", "-t", "get_outputs"], text=True)
        import json

        outputs = json.loads(out)
        for o in outputs:
            if o["name"] == OUTPUT:
                return str(o.get("scale", "1"))
    except Exception:
        return "1"
    return "1"


def set_scale(scale, resolution):
    subprocess.run(
        ["swaymsg", "output", OUTPUT, "scale", scale, "resolution", resolution],
        check=False,
    )


class TrayApp:
    def __init__(self):
        self.indicator = AppIndicator3.Indicator.new(
            APP_ID,
            "video-display-symbolic",
            AppIndicator3.IndicatorCategory.SYSTEM_SERVICES,
        )
        self.indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)
        self.menu = Gtk.Menu()
        self.indicator.set_menu(self.menu)
        self.refresh_menu()

    def refresh_menu(self):
        # Clear menu
        for child in self.menu.get_children():
            self.menu.remove(child)

        current = get_current_scale()

        for label, scale, resolution in SCALES:
            display_label = label
            if scale == current:
                label = f"✔ {scale}"
            item = Gtk.MenuItem(label=display_label)
            item.connect("activate", self.on_select, scale, resolution)
            item.show()
            self.menu.append(item)

        self.menu.append(Gtk.SeparatorMenuItem())

        quit_item = Gtk.MenuItem(label="Quit")
        quit_item.connect("activate", Gtk.main_quit)
        quit_item.show()
        self.menu.append(quit_item)

        self.menu.show_all()
        return False

    def on_select(self, _, scale, resolution):
        set_scale(scale, resolution)
        GLib.idle_add(self.refresh_menu)


def main():
    try:
        TrayApp()
        Gtk.main()
    except Exception as _:
        print("Another instance is already running.")
        exit(0)


if __name__ == "__main__":
    main()
