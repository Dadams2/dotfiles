local settings = require("settings")
local colors = require("colors")

local background = settings.defaults.background
local icon = settings.defaults.icon
local label = settings.defaults.label

-- Equivalent to the --default domain
sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.icon_font,
      style = settings.font.style_map[icon.style],
      size = icon.size,
    },
    color = colors.icon_color,
    y_offset = icon.y_offset,
    padding_left = icon.padding_left,
    padding_right = icon.padding_right,
    background = { image = { corner_radius = background.corner_radius } },
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map[label.style],
      size = label.size,
    },
    color = colors.label_color,
    y_offset = label.y_offset,
    padding_left = label.padding_left,
    padding_right = label.padding_right,
  },
  background = {
    color = colors.item.bg,
    height = background.height,
    corner_radius = background.corner_radius,
    padding_left = background.padding_left,
    padding_right = background.padding_right,
    border_width = 0,
  },
  popup = {
    background = {
      border_width = 2,
      corner_radius = 9,
      border_color = colors.popup.border,
      color = colors.popup.bg,
      shadow = { drawing = true },
    },
    blur_radius = 40,
  },
  padding_left = settings.defaults.padding_left,
  padding_right = settings.defaults.padding_right,
  scroll_texts = true,
})
