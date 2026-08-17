local colors = require("colors")
local settings = require("settings")

-- Equivalent to the --bar domain
sbar.bar({
  height = settings.bar.height,
  color = colors.bar.bg,
  padding_right = settings.bar.padding_right,
  padding_left = settings.bar.padding_left,
  y_offset = settings.bar.y_offset,
  margin = settings.bar.margin,
  sticky = settings.bar.sticky,
  notch_width = settings.bar.notch_width,
  display = settings.bar.display,
})
