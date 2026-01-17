#!/usr/bin/env python3

import os

# Pasta onde os scripts serão criados
script_dir = os.path.expanduser("~/.local/bin/")
os.makedirs(script_dir, exist_ok=True)

# Arquivo TOML
config_file = "configs.toml"
configs = {}
current_name = None

# Parse manual do TOML
with open(config_file) as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("[") and line.endswith("]"):
            current_name = line[1:-1].strip()
            configs[current_name] = {}
        elif "=" in line and current_name:
            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip().strip('"')
            # Converte True/False em boolean
            if value.lower() == "true":
                value = True
            elif value.lower() == "false":
                value = False
            configs[current_name][key] = value

# Lista de scripts atuais
existing_scripts = set(f for f in os.listdir(script_dir) if f.endswith(".fish"))

# Lista de scripts que devem existir
expected_scripts = set()
for name, cfg in configs.items():
    script_name = name
    if not script_name.endswith(".fish"):
        script_name += ".fish"
    expected_scripts.add(script_name)

# Remove scripts antigos que não estão na config
for script in existing_scripts - expected_scripts:
    os.remove(os.path.join(script_dir, script))
    print(f"Apagado script antigo: {script}")

# Gera ou atualiza scripts Fish
for name, cfg in configs.items():
    message = cfg.get("message", "Enter input")
    new_term = cfg.get("new_term", False)
    script_path = os.path.join(script_dir, name)

    if not script_path.endswith(".fish"):
        script_path += ".fish"

    # Escolhe o comando dependendo do new_term
    if new_term:
        run_line = f'alacritty -e fish -c "\\"$NAME\\" \\"$QUERY\\""'
    else:
        run_line = f'"$NAME" "$QUERY"'

    script_content = f"""#!/usr/bin/env fish

set NAME "{name}"
set MESSAGE "{message}"
set QUERY (echo "" | rofi -dmenu -show-icons -theme rounded-gray-dark -p "$NAME [$MESSAGE]:")

if test -n "$QUERY"
    {run_line}
end
"""

    with open(script_path, "w") as f:
        f.write(script_content)
    os.chmod(script_path, 0o755)

print(f"Scripts criados/atualizados em {script_dir}, scripts obsoletos removidos.")
