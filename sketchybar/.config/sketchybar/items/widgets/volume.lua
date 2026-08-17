local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 250

local volume = sbar.add("item", "widgets.volume", {
  position = "right",
  icon = {
    string = icons.volume._100,
    color = colors.blue,
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
  },
  label = {
    string = "??%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Semibold"],
      size = 12.0,
    },
  },
  popup = { align = "center" }
})

local volume_slider = sbar.add("slider", popup_width, {
  position = "popup." .. volume.name,
  slider = {
    highlight_color = colors.blue,
    background = {
      height = 6,
      corner_radius = 3,
      color = colors.bg2,
    },
    knob= {
      string = "􀀁",
      drawing = true,
    },
  },
  background = { color = colors.bg1, height = 2, y_offset = -20 },
  click_script = 'osascript -e "set volume output volume $PERCENTAGE"'
})

volume:subscribe("volume_change", function(env)
  local volume_level = tonumber(env.INFO)
  local icon = icons.volume._0
  if volume_level > 60 then
    icon = icons.volume._100
  elseif volume_level > 30 then
    icon = icons.volume._66
  elseif volume_level > 10 then
    icon = icons.volume._33
  elseif volume_level > 0 then
    icon = icons.volume._10
  end

  local lead = ""
  if volume_level < 10 then
    lead = "0"
  end

  volume:set({
    icon = { string = icon },
    label = { string = lead .. volume_level .. "%" },
  })
  volume_slider:set({ slider = { percentage = volume_level } })
end)

local function volume_collapse_details()
  local drawing = volume:query().popup.drawing == "on"
  if not drawing then return end
  volume:set({ popup = { drawing = false } })
  sbar.remove('/volume.device\\.*/')
end

local current_audio_device = "None"
local function volume_toggle_details(env)
  if env.BUTTON == "right" then
    sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
    return
  end

  local should_draw = volume:query().popup.drawing == "off"
  if should_draw then
    volume:set({ popup = { drawing = true } })
    sbar.exec("SwitchAudioSource -t output -c", function(result)
      current_audio_device = result:sub(1, -2)
      sbar.exec("SwitchAudioSource -a -t output", function(available)
        current = current_audio_device
        local color = colors.grey
        local counter = 0

        for device in string.gmatch(available, '[^\r\n]+') do
          local color = colors.grey
          if current == device then
            color = colors.white
          end
          sbar.add("item", "volume.device." .. counter, {
            position = "popup." .. volume.name,
            width = popup_width,
            align = "center",
            label = { string = device, color = color },
            click_script = 'SwitchAudioSource -s "' .. device .. '" && sketchybar --set /volume.device\\.*/ label.color=' .. colors.grey .. ' --set $NAME label.color=' .. colors.white

          })
          counter = counter + 1
        end
      end)
    end)
  else
    volume_collapse_details()
  end
end

local function volume_scroll(env)
  local delta = env.INFO.delta
  if not (env.INFO.modifier == "ctrl") then delta = delta * 10.0 end

  sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume:subscribe("mouse.clicked", volume_toggle_details)
volume:subscribe("mouse.exited.global", volume_collapse_details)
volume:subscribe("mouse.scrolled", volume_scroll)

