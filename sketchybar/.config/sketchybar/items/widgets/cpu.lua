local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0")

local cpu = sbar.add("graph", "widgets.cpu" , 32, {
  position = "right",
  graph = { color = colors.blue },
  background = {
    height = settings.defaults.background.height,
    color = colors.item.bg,
    corner_radius = settings.defaults.background.corner_radius,
    border_width = 0,
    drawing = true,
  },
  icon = {
    string = icons.cpu,
    color = colors.blue,
  },
  label = {
    string = "--%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 11.0,
    },
    align = "right",
    padding_right = 4,
    width = 0,
    y_offset = 0,
  },
  padding_right = 0,
})

cpu:subscribe("cpu_update", function(env)
  -- Also available: env.user_load, env.sys_load
  local load = tonumber(env.total_load)
  cpu:push({ load / 100. })

  local color = colors.blue
  if load > 30 then
    if load < 60 then
      color = colors.yellow
    elseif load < 80 then
      color = colors.orange
    else
      color = colors.red
    end
  end

  cpu:set({
    graph = { color = color },
    label = string.format("%d%%", load),
  })
end)

cpu:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a 'Activity Monitor'")
end)
