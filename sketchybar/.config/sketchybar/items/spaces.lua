local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local function trim(value)
  if not value then
    return ""
  end

  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function command_output(command)
  local handle = io.popen(command)
  if not handle then
    return ""
  end

  local output = handle:read("*a")
  handle:close()

  return trim(output)
end

local function resolve_space_ids()
  local output = command_output("yabai -m query --spaces | jq -r '.[] | \"\\(.index) \\(.display)\"'")
  local spaces = {}

  for line in output:gmatch("[^\r\n]+") do
    local space_id, display_id = line:match("^(%d+)%s+(%d+)$")
    if space_id and display_id then
      table.insert(spaces, {
        id = tonumber(space_id),
        display = tonumber(display_id),
      })
    end
  end

  if #spaces == 0 then
    for i = 1, 7, 1 do
      table.insert(spaces, { id = i })
    end
  end

  return spaces
end

local function current_space_id()
  return tonumber(command_output("yabai -m query --spaces --space | jq -r '.index'"))
end

local function space_style(selected)
  return {
    icon = {
      color = selected and colors.black or colors.white,
    },
    label = {
      color = selected and colors.black or colors.grey,
    },
    background = {
      color = selected and colors.item.current_space or colors.item.bg,
    },
  }
end

local spaces = {}
local selected_space = current_space_id()

for _, space_config in ipairs(resolve_space_ids()) do
  local space_id = space_config.id
  local selected = space_id == selected_space
  local space = sbar.add("space", "space." .. space_id, {
    space = space_id,
    display = space_config.display,
    position = "left",
    icon = {
      string = tostring(space_id),
      font = {
        family = settings.font.numbers,
        style = settings.font.style_map["Bold"],
        size = 13.0,
      },
      color = selected and colors.black or colors.white,
      padding_left = 9,
      padding_right = 9,
    },
    label = {
      string = " —",
      color = selected and colors.black or colors.grey,
      font = "sketchybar-app-font:Regular:12.0",
      padding_left = 0,
      padding_right = 7,
      y_offset = -1,
    },
    padding_left = 2,
    padding_right = 2,
    background = {
      color = selected and colors.item.current_space or colors.item.bg,
      height = settings.defaults.background.height,
      corner_radius = settings.defaults.background.corner_radius,
      border_width = 0,
    },
  })

  spaces[space_id] = space

  space:subscribe("space_change", function(env)
    space:set(space_style(env.SELECTED == "true"))
  end)

  space:subscribe("mouse.clicked", function(env)
    local op = (env.BUTTON == "right") and "--destroy" or "--focus"
    sbar.exec("yabai -m space " .. op .. " " .. env.SID)
  end)
end

local space_window_observer = sbar.add("item", "spaces.observer", {
  drawing = false,
  updates = true,
})

space_window_observer:subscribe("space_windows_change", function(env)
  local icon_line = ""
  local no_app = true

  for app, _ in pairs(env.INFO.apps) do
    no_app = false
    local lookup = app_icons[app]
    local icon = lookup or app_icons["Default"]
    icon_line = icon_line .. icon
  end

  if no_app then
    icon_line = " —"
  end

  if spaces[env.INFO.space] then
    spaces[env.INFO.space]:set({
      label = {
        string = icon_line,
      },
    })
  end
end)

sbar.add("item", "spaces.padding", {
  position = "left",
  icon = { drawing = false },
  label = { drawing = false },
  background = { drawing = false },
  width = settings.group_paddings,
})
