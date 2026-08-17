local colors = require("colors")
local settings = require("settings")

-- Moon icon background (left of weather label)
local weather_moon = sbar.add("item", "weather.moon", {
  position = "q",
  drawing = false,
  icon = {
    font = {
      family = settings.inspired_icon_font,
      style = settings.font.style_map["Bold"],
      size = 22.0,
    },
    color = colors.black,
    padding_left = 4,
    padding_right = 3,
  },
  label = { drawing = false },
  background = {
    color = colors.item.weather_moon,
    corner_radius = 5,
    height = 26,
    border_width = 0,
  },
  padding_right = -1,
})

-- Weather label (temperature + description)
local weather = sbar.add("item", "weather", {
  position = "q",
  drawing = false,
  icon = {
    string = "",
    color = colors.pink,
    font = {
      family = settings.inspired_icon_font,
      style = settings.font.style_map["Bold"],
      size = 15.0,
    },
  },
  label = {
    drawing = false,
    color = colors.white,
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Semibold"],
      size = 12.0,
    },
    max_chars = 40,
  },
  background = {
    color = colors.item.bg,
    corner_radius = 5,
    height = 26,
    border_width = 0,
  },
  update_freq = 1800,
})

local function update_weather()
  weather:set({
    drawing = true,
    label = {
      drawing = true,
      string = "Loading weather",
    },
  })
  weather_moon:set({ drawing = false })
  sbar.exec("NAME=weather SENDER=forced $CONFIG_DIR/config-inspiration/plugins/weather.sh")
end

weather:subscribe({ "routine", "system_woke" }, function(env)
  update_weather()
end)

weather:subscribe("mouse.clicked", function(env)
  update_weather()
end)

weather_moon:subscribe("mouse.clicked", function(env)
  update_weather()
end)

sbar.delay(1, update_weather)
