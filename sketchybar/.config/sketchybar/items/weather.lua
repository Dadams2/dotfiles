local colors = require("colors")
local settings = require("settings")

local moon_icons = {
  ["New Moon"] = "",
  ["Waxing Crescent"] = "",
  ["First Quarter"] = "",
  ["Waxing Gibbous"] = "",
  ["Full Moon"] = "",
  ["Waning Gibbous"] = "",
  ["Last Quarter"] = "",
  ["Waning Crescent"] = "",
}

local function url_encode(value)
  return (value:gsub("[^%w%-._~]", function(character)
    return string.format("%%%02X", string.byte(character))
  end))
end

local function parse_fields(output, expected_count)
  local fields = {}
  output = (output or ""):gsub("[\r\n]+$", "")

  for field in (output .. "\t"):gmatch("(.-)\t") do
    fields[#fields + 1] = field
  end

  if #fields ~= expected_count then
    return nil
  end

  return fields
end

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

local request_id = 0

local function show_fallback(location)
  weather:set({
    drawing = true,
    label = {
      drawing = true,
      string = location ~= "" and location or "Weather unavailable",
    },
  })
  weather_moon:set({
    drawing = false,
    icon = { string = "" },
  })
end

local function update_weather()
  request_id = request_id + 1
  local current_request = request_id

  weather:set({
    drawing = true,
    label = {
      drawing = true,
      string = "Loading weather",
    },
  })
  weather_moon:set({ drawing = false })

  local location_command = [[
curl --fail --silent --show-error --max-time 10 https://ipinfo.io/json |
  jq -r '[.city // "", .region // ""] | @tsv' 2>/dev/null
]]

  sbar.exec(location_command, function(location_output)
    if current_request ~= request_id then
      return
    end

    local location_fields = parse_fields(location_output, 2)
    if not location_fields or location_fields[1] == "" then
      show_fallback("")
      return
    end

    local location = location_fields[1]
    local region = location_fields[2]
    local weather_url = "https://wttr.in/" .. url_encode(location .. " " .. region) .. "?format=j1"
    local weather_command = string.format([[
curl --fail --silent --show-error --max-time 15 '%s' |
  jq -r '[
    .current_condition[0].temp_C // "",
    .current_condition[0].weatherDesc[0].value // "",
    .weather[0].astronomy[0].moon_phase // ""
  ] | @tsv' 2>/dev/null
]], weather_url)

    sbar.exec(weather_command, function(weather_output)
      if current_request ~= request_id then
        return
      end

      local weather_fields = parse_fields(weather_output, 3)
      if not weather_fields or weather_fields[1] == "" then
        show_fallback(location)
        return
      end

      local temperature = weather_fields[1]
      local description = weather_fields[2]
      if #description > 25 then
        description = description:sub(1, 25) .. "..."
      end

      weather:set({
        drawing = true,
        label = {
          drawing = true,
          string = location .. "  " .. temperature .. "℃ " .. description,
        },
      })

      local moon_icon = moon_icons[weather_fields[3]]
      weather_moon:set({
        drawing = moon_icon ~= nil,
        icon = { string = moon_icon or "" },
      })
    end)
  end)
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
