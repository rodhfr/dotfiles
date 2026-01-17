import subprocess
import json
import sys 
import re
from pathlib import Path

def writeStatus(active_layers): 
    data = {
        "text": " + ".join(active_layers)
    }
    print(data) 
    return 0 

try: 
    proc = subprocess.Popen( ["sudo", "-n", "keyd", "listen"],
                            stdout=subprocess.PIPE, 
                            stderr=subprocess.PIPE, 
                            text=True 
                            ) 
except FileNotFoundError: 
        status = "Keyd not in PATH."
        write(status)
        sys.exit(1) 

layers = []
toggle_layers = []

homedir = Path.home()
with open(f"{homedir}/.config/keyd/default.conf", "r") as f:
    data_conff = f.read()

regex_layer = r"\[([^\]]+)\]"
layers = re.findall(regex_layer, data_conff)
layers = [l for l in layers if l.strip() != "main"]
#print("Toggle layers:", layers)

regex_toggle = r"toggle\(\s*([^)]+?)\s*\)"
toggle_layers = re.findall(regex_toggle, data_conff)
#print("Toggle layers:", toggle_layers)


active_layers = []

for line in proc.stdout: 
    stdout = line.strip() 
    layer_plus = "+" in stdout
    layer_minus = "-" in stdout
    #print("STDOUT:", stdout) 

    for layer in layers: 

        layer_call = layer in stdout

        if layer_call:

            # layer_toggle returns boolean if layer is toggle
            layer_toggle = layer in toggle_layers
            # layer_already_active returns boolean if layer is toggle
            layer_already_active = layer in active_layers
            # layer_ready_to_remove returns boolean if layer is ready to action 
            layer_ready_to_remove = layer_minus and layer_already_active
            # layer_ready_to_append returns boolean if layer is ready to action 
            layer_ready_to_append = layer_plus and not layer_already_active

            if layer_toggle:
                if layer_ready_to_append:
                    active_layers = [layer]
                if layer_ready_to_remove:
                    active_layers.remove(layer)
            else:
                if layer_ready_to_append:
                    active_layers.append(layer)
                if layer_ready_to_remove:
                    active_layers.remove(layer)

    writeStatus(active_layers)
