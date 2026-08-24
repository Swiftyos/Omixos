-- Strict mock of Hyprland's Lua config API, driven by the surface extracted
-- from the pinned Hyprland's own source (see extract-surface.py). Names the
-- shipped compositor does not register are nil here, so config code that
-- would die with "attempt to call/index a nil value" on a user's machine
-- dies the same way inside this check.

local surface_path = os.getenv("HL_SURFACE")
assert(surface_path, "HL_SURFACE must point at the generated surface.lua")
local surface = dofile(surface_path)

local M = {}

M.config_errors = {}
local function add_error(msg)
  table.insert(M.config_errors, msg)
end
M.add_error = add_error

local EVENTS = {}
for _, event in ipairs(surface.events) do
  EVENTS[event] = true
end

local MONITOR_FIELDS = {}
for _, field in ipairs(surface.monitor_fields) do
  MONITOR_FIELDS[field] = true
end

M.handlers = {}
M.timers = {}
M.state = { active_monitor = nil, monitors = {} }

-- Value shapes matching LuaMonitor.cpp. Only fields present in the extracted
-- surface are exposed; the rest read as nil, exactly like the shipped
-- compositor. Fields the surface knows but this table does not default to a
-- number, the most common Lua-side type.
local function monitor_shapes(spec)
  return {
    id = spec.id or 0,
    name = spec.name or "HDMI-A-1",
    description = spec.description or "Mock Display",
    serial = spec.serial or "0000",
    width = spec.width or 1920,
    height = spec.height or 1080,
    physical_width = spec.physical_width or 600,
    physical_height = spec.physical_height or 340,
    refresh_rate = spec.refresh_rate or 60.0,
    x = spec.x or 0,
    y = spec.y or 0,
    active_workspace = spec.active_workspace,
    active_special_workspace = nil,
    position = { x = spec.x or 0, y = spec.y or 0 },
    size = { width = spec.width or 1920, height = spec.height or 1080 },
    scale = spec.scale or 1.0,
    transform = 0,
    dpms_status = true,
    vrr_active = false,
    is_mirror = false,
    mirrors = {},
    available_modes = {
      {
        width = spec.width or 1920,
        height = spec.height or 1080,
        refresh_rate = 60.0,
        preferred = true,
      },
    },
    focused = true,
    cm = "srgb",
    reserved = spec.reserved or { top = 0, right = 0, bottom = 0, left = 0 },
    set_workspace = function() end,
    set_special_workspace = function() end,
  }
end

-- An "expired" monitor answers nil to every key, matching upstream's handling
-- of a handle whose output has gone away.
function M.make_monitor(spec)
  local shapes = spec.expired and {} or monitor_shapes(spec)
  return setmetatable({}, {
    __index = function(_, key)
      if spec.expired or not MONITOR_FIELDS[key] then
        return nil
      end
      local value = shapes[key]
      if value == nil then
        return 1
      end
      return value
    end,
    __newindex = function()
      error("monitors are read-only userdata in Hyprland", 2)
    end,
    __tostring = function()
      if spec.expired then
        return "HL.Monitor(expired)"
      end
      return string.format("HL.Monitor(%d:%s)", shapes.id, shapes.name)
    end,
  })
end

local hl_real = {}

for _, name in ipairs(surface.fns) do
  hl_real[name] = function() end
end

-- The hl.dsp namespace, exactly as the shipped compositor registers it.
-- Dispatchers return an opaque token, the shape hl.bind accepts.
local function dsp_group(names)
  local group = {}
  for _, name in ipairs(names) do
    group[name] = function(...)
      return { __mock_dispatcher = name, ... }
    end
  end
  return group
end

hl_real.dsp = dsp_group(surface.dsp[""])
for group, names in pairs(surface.dsp) do
  if group ~= "" then
    hl_real.dsp[group] = dsp_group(names)
  end
end

-- Value-returning and behavioral overrides for registered names.
local overrides = {
  get_active_monitor = function()
    return M.state.active_monitor
  end,
  get_monitors = function()
    return M.state.monitors
  end,
  get_monitor = function()
    return M.state.active_monitor
  end,
  get_monitor_at = function()
    return M.state.active_monitor
  end,
  get_monitor_at_cursor = function()
    return M.state.active_monitor
  end,
  get_active_window = function() return nil end,
  get_last_window = function() return nil end,
  get_urgent_window = function() return nil end,
  get_active_workspace = function() return nil end,
  get_active_special_workspace = function() return nil end,
  get_last_workspace = function() return nil end,
  get_workspaces = function() return {} end,
  get_windows = function() return {} end,
  get_workspace_windows = function() return {} end,
  get_layers = function() return {} end,
  get_loaded_plugins = function() return {} end,
  get_cursor_pos = function() return { x = 0, y = 0 } end,
  get_current_submap = function() return "" end,
  is_key_down = function() return false end,
  get = function() return nil end,
  get_config = function() return nil end,
  version = function()
    return { version = "mock" }
  end,
  on = function(event, fn)
    if type(event) ~= "string" or not EVENTS[event] then
      add_error(string.format('hl.on: no such event "%s"', tostring(event)))
      return
    end
    if type(fn) ~= "function" then
      add_error(string.format('hl.on("%s"): handler must be a function', event))
      return
    end
    M.handlers[event] = M.handlers[event] or {}
    table.insert(M.handlers[event], fn)
  end,
  timer = function(a, b)
    -- Accept both (opts) and (interval, fn) shapes; capture any function so
    -- the driver can execute timer bodies, which --verify-config never runs.
    local candidates = { a, b }
    if type(a) == "table" then
      for _, value in pairs(a) do
        table.insert(candidates, value)
      end
    end
    for _, value in ipairs(candidates) do
      if type(value) == "function" then
        table.insert(M.timers, value)
      end
    end
  end,
}

for name, fn in pairs(overrides) do
  if hl_real[name] ~= nil then
    hl_real[name] = fn
  end
end

M.hl = hl_real

function M.fire(event, ...)
  local failures = {}
  for _, fn in ipairs(M.handlers[event] or {}) do
    local ok, err = xpcall(fn, debug.traceback, ...)
    if not ok then
      table.insert(failures, err)
    end
  end
  return failures
end

function M.reset_handlers()
  M.handlers = {}
  M.timers = {}
end

return M
