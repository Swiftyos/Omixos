local home = os.getenv("HOME") or ""
local disabled = io.open(home .. "/.local/state/omarchy/toggles/voxtype-disabled", "r")

if disabled then
  disabled:close()
else
  o.bind("SUPER + CTRL + X", "Toggle dictation", "voxtype record toggle")
  o.bind("F9", "Start dictation (push-to-talk)", "voxtype record start")
  o.bind("F9", "Stop dictation (push-to-talk)", "voxtype record stop", { release = true })
end
