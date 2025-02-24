local wezterm = require 'wezterm'

-- return {
--   font = wezterm.font('Fira Code'),
--   font_size = 12,
-- }

return {
  font = wezterm.font {
    family = 'JetBrains Mono',
    harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
  },
  window_background_opacity = 0.7,
  font_size = 12,
  window_close_confirmation = 'NeverPrompt',
  keys = {
    -- spawn commands
    {key = 'h', mods = 'CTRL', action = wezterm.action.SpawnCommandInNewTab { args = { 'htop' } }},
    -- change tabs
    {key = '1', mods = 'CTRL', action = wezterm.action.ActivateTab(0)},
    {key="2", mods="CTRL", action=wezterm.action{ActivateTab=1}},
    {key="3", mods="CTRL", action=wezterm.action{ActivateTab=2}},
    {key="4", mods="CTRL", action=wezterm.action{ActivateTab=3}},
    {key="5", mods="CTRL", action=wezterm.action{ActivateTab=4}},
    {key="6", mods="CTRL", action=wezterm.action{ActivateTab=5}},
    {key="7", mods="CTRL", action=wezterm.action{ActivateTab=6}},
    {key="8", mods="CTRL", action=wezterm.action{ActivateTab=7}},
    {key="9", mods="CTRL", action=wezterm.action{ActivateTab=8}},
    -- new tab
    {key="t", mods="CTRL", action=wezterm.action.SpawnCommandInNewTab { args = { 'bash' } }},
    -- close current tab
    {key="w", mods="CTRL", action=wezterm.action.CloseCurrentPane { confirm = false } }
  },
}

