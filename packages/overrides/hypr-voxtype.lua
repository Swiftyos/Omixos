-- VoxType stays declarative on OmixOS: the daemon ships only when
-- programs.omarchy.dictation is enabled, and Remove > AI > Dictation writes a
-- disable toggle instead of uninstalling a package. Bind the keys only while
-- the binary exists and the user has not disabled dictation, so F9 keeps
-- reaching applications everywhere else.
local home = os.getenv("HOME") or ""
local disabled = io.open(home .. "/.local/state/omarchy/toggles/voxtype-disabled", "r")

if disabled then
  disabled:close()
elseif o.cmd_present("voxtype") then
  o.bind("SUPER + CTRL + X", "Toggle dictation", "voxtype record toggle")
  o.bind("F9", "Start dictation (push-to-talk)", "voxtype record start")
  o.bind("F9", "Stop dictation (push-to-talk)", "voxtype record stop", { release = true })
end
