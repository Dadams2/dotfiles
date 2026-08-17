local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local whitelist = { ["Spotify"] = true,
                    ["Music"] = true    };

local media = sbar.add("item", "media", {
  position = "e",
  icon = {
    string = app_icons["Spotify"] or app_icons["Default"],
    font = "sketchybar-app-font:Regular:16.0",
    color = colors.yellow,
  },
  label = {
    drawing = false,
    max_chars = 35,
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 12.0,
    },
  },
  drawing = false,
  updates = true,
  popup = {
    align = "center",
    horizontal = true,
  }
})

sbar.add("item", {
  position = "popup." .. media.name,
  icon = { string = icons.media.back },
  label = { drawing = false },
  click_script = "nowplaying-cli previous",
})
sbar.add("item", {
  position = "popup." .. media.name,
  icon = { string = icons.media.play_pause },
  label = { drawing = false },
  click_script = "nowplaying-cli togglePlayPause",
})
sbar.add("item", {
  position = "popup." .. media.name,
  icon = { string = icons.media.forward },
  label = { drawing = false },
  click_script = "nowplaying-cli next",
})

local function hide_media_popup()
  media:set({ popup = { drawing = false } })
end

media:subscribe("media_change", function(env)
  if whitelist[env.INFO.app] then
    local is_playing = env.INFO.state == "playing"
    local is_visible = is_playing or env.INFO.state == "paused"

    if is_visible then
      local label = env.INFO.title or ""
      if env.INFO.artist and env.INFO.artist ~= "" then
        label = label .. " • " .. env.INFO.artist
      end

      media:set({
        drawing = true,
        icon = {
          string = app_icons[env.INFO.app] or app_icons["Default"],
          color = is_playing and colors.green or colors.yellow,
        },
        label = {
          drawing = is_playing,
          string = label,
        },
      })
    else
      media:set({ drawing = false, popup = { drawing = false } })
    end
  else
    media:set({ drawing = false, popup = { drawing = false } })
  end
end)

media:subscribe("mouse.clicked", function(env)
  media:set({ popup = { drawing = "toggle" }})
end)

media:subscribe("mouse.exited.global", function(env)
  hide_media_popup()
end)
