local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local separator_size = settings.profile == "desktop" and 23.0 or 20.0
local label_size = settings.profile == "desktop" and 16.0 or 12.0

local front_app = sbar.add("item", "front_app", {
  position = "left",
  display = "active",
  icon = {
    string = app_icons["Finder"],
    font = "sketchybar-app-font:Regular:16.0",
    color = colors.black,
    padding_left = 8,
    padding_right = 5,
  },
  label = { drawing = false },
  background = {
    color = colors.item.front_app,
    padding_left = 0,
    padding_right = 0,
  },
  padding_left = 0,
  padding_right = 0,
  updates = true,
})

local front_app_separator = sbar.add("item", "front_app.separator", {
  position = "left",
  display = "active",
  icon = {
    string = "",
    color = colors.item.front_app,
    font = {
      family = settings.icon_font,
      style = settings.font.style_map["Heavy"],
      size = separator_size,
    },
    padding_left = 0,
    padding_right = 0,
    y_offset = 1,
  },
  label = { drawing = false },
  background = {
    drawing = false,
  },
  padding_left = -3,
  padding_right = 0,
})

local front_app_name = sbar.add("item", "front_app.name", {
  position = "left",
  display = "active",
  icon = { drawing = false },
  label = {
    string = "Finder",
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = label_size,
    },
    max_chars = 20,
    padding_left = 0,
    padding_right = 0,
  },
  background = {
    drawing = false,
  },
  padding_left = 0,
  padding_right = 0,
  updates = true,
})

sbar.add("item", "front_app.padding", {
  position = "left",
  display = "active",
  icon = { drawing = false },
  label = { drawing = false },
  background = { drawing = false },
  width = settings.group_paddings,
})

local function set_front_app(app_name)
  local icon = app_icons[app_name] or app_icons["Default"]

  front_app:set({
    icon = { string = icon },
  })

  front_app_name:set({
    label = { string = app_name },
  })
end

front_app:subscribe("front_app_switched", function(env)
  set_front_app(env.INFO)
end)
