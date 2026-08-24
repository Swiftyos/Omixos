-- Drive the omarchy Hyprland Lua config through a simulated session
-- lifecycle against the strict shipped-API mock: monitorless load (what
-- --verify-config covers), first monitor plug and its events, timer bodies,
-- focus hops, reserved-area changes, a HiDPI monitor, a config reload with a
-- live monitor (the omarchy-hw-autoscale path), and monitor expiry.
--
-- Usage: HOME=<seeded home> OMARCHY_PATH=<runtime share/omarchy>
--        HL_SURFACE=<surface.lua> lua run.lua

local script_dir = arg[0]:match("^(.*)/") or "."
package.path = script_dir .. "/?.lua;" .. package.path
local mock = require("hl-mock")

_G.hl = mock.hl

local failures = {}
local function phase(name, fn)
  local ok, err = xpcall(fn, debug.traceback)
  if not ok then
    table.insert(failures, { phase = name, err = err })
  end
end

local function fire(name, event, ...)
  for _, err in ipairs(mock.fire(event, ...)) do
    table.insert(failures, { phase = name .. " [" .. event .. "]", err = err })
  end
end

local home = os.getenv("HOME")
assert(home, "HOME must be set")
local config_entry = home .. "/.config/hypr/hyprland.lua"

local function fire_session_events(name, monitor)
  fire(name, "monitor.added", monitor)
  fire(name, "monitor.focused", monitor)
  fire(name, "monitor.layout_changed")
  fire(name, "hyprland.start")
  phase(name .. " [timers]", function()
    for _, fn in ipairs(mock.timers) do
      fn()
    end
  end)
end

-- PHASE load: monitorless parse and run, the --verify-config equivalent.
phase("load", function()
  dofile(config_entry)
end)

-- PHASE plug: the first real monitor appears and the session starts.
local monitor = mock.make_monitor({ id = 0, name = "HDMI-A-1" })
mock.state.active_monitor = monitor
mock.state.monitors = { monitor }
fire_session_events("plug", monitor)

-- PHASE hop: monitor.focused fires again on every focus hop.
fire("hop", "monitor.focused", monitor)

-- PHASE reserve: a bar reserves area and the layout changes.
local reserved_monitor = mock.make_monitor({
  id = 0,
  name = "HDMI-A-1",
  reserved = { top = 40, right = 0, bottom = 0, left = 0 },
})
mock.state.active_monitor = reserved_monitor
mock.state.monitors = { reserved_monitor }
fire("reserve", "monitor.layout_changed")
fire("reserve", "monitor.focused", reserved_monitor)

-- PHASE scaled: a HiDPI laptop panel, the seeded upstream default.
local scaled_monitor = mock.make_monitor({
  id = 1,
  name = "eDP-1",
  width = 2880,
  height = 1800,
  scale = 2.0,
  reserved = { top = 40, right = 0, bottom = 0, left = 0 },
})
mock.state.active_monitor = scaled_monitor
mock.state.monitors = { scaled_monitor }
fire("scaled", "monitor.added", scaled_monitor)
fire("scaled", "monitor.focused", scaled_monitor)
fire("scaled", "monitor.layout_changed")

-- PHASE reload: hyprctl reload with a live monitor, the path
-- omarchy-hw-autoscale and omarchy-theme-set trigger at session start.
-- Hyprland rebuilds the Lua config state, so handlers re-register from
-- scratch and the whole config re-executes with the monitor present.
mock.reset_handlers()
phase("reload", function()
  dofile(config_entry)
end)
fire_session_events("reload", scaled_monitor)

-- PHASE expire: the output goes away; its handle answers nil to every field.
local dead = mock.make_monitor({ expired = true })
mock.state.active_monitor = dead
mock.state.monitors = {}
fire("expire", "monitor.removed", dead)
fire("expire", "monitor.layout_changed")

fire("shutdown", "config.reloaded")
fire("shutdown", "hyprland.shutdown")

local exit = 0
if #mock.config_errors > 0 then
  exit = 1
  print("CONFIG ERRORS (" .. #mock.config_errors .. "):")
  for _, err in ipairs(mock.config_errors) do
    print("  " .. err)
  end
end
if #failures > 0 then
  exit = 1
  print("LUA FAILURES (" .. #failures .. "):")
  for _, failure in ipairs(failures) do
    print("== phase " .. failure.phase .. " ==")
    print(failure.err)
    print("")
  end
end
if exit == 0 then
  print("hyprland-lua-runtime: full simulated session ran clean")
end
os.exit(exit)
