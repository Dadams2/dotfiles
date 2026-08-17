local settings = require("settings")
local colors = require("colors")

local clock = sbar.add("item", "clock", {
  position = "right",
  icon = {
    string = "󰃰",
    color = colors.item.clock,
    font = {
      family = settings.icon_font,
      style = settings.font.style_map["Bold"],
      size = 15.0,
    },
  },
  label = {
    color = colors.white,
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = settings.profile == "desktop" and 14.0 or 12.0,
    },
  },
  update_freq = 10,
  click_script = "open -a 'Calendar'"
})

clock:subscribe({ "forced", "routine", "system_woke" }, function(env)
  clock:set({ label = os.date("%a %b %d %H:%M") })
end)
