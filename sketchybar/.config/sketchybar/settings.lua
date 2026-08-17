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

local function resolve_profile()
  local machine = trim(os.getenv("MACHINE"))
  if machine == "laptop" then
    return "laptop"
  end

  if machine ~= "" then
    return "desktop"
  end

  local display_type = command_output("system_profiler SPDisplaysDataType | grep -B 3 'Main Display:' | awk '/Display Type/ {print $3; exit}'")
  if display_type == "Built-in" then
    return "laptop"
  end

  return "desktop"
end

local font = {
  text = "JetBrainsMono Nerd Font",
  numbers = "JetBrainsMono Nerd Font",
  style_map = {
    ["Regular"] = "Regular",
    ["Semibold"] = "Medium",
    ["Bold"] = "SemiBold",
    ["Heavy"] = "Bold",
    ["Black"] = "ExtraBold",
  },
}

local profiles = {
  laptop = {
    bar = {
      height = 32,
      margin = 0,
      padding_left = 23,
      padding_right = 23,
      y_offset = 0,
      notch_width = 188,
      display = "all",
      sticky = true,
    },
    defaults = {
      padding_left = 5,
      padding_right = 5,
      background = {
        height = 26,
        corner_radius = 5,
        padding_left = 0,
        padding_right = 5,
      },
      icon = {
        style = "Semibold",
        size = 15.0,
        y_offset = 0,
        padding_left = 5,
        padding_right = 5,
      },
      label = {
        style = "Semibold",
        size = 12.0,
        y_offset = 0,
        padding_left = 0,
        padding_right = 5,
      },
    },
    group_paddings = 6,
  },
  desktop = {
    bar = {
      height = 32,
      margin = 0,
      padding_left = 0,
      padding_right = 0,
      y_offset = 0,
      notch_width = 188,
      display = "all",
      sticky = true,
    },
    defaults = {
      padding_left = 5,
      padding_right = 5,
      background = {
        height = 32,
        corner_radius = 5,
        padding_left = 0,
        padding_right = 5,
      },
      icon = {
        style = "Semibold",
        size = 20.0,
        y_offset = 1,
        padding_left = 5,
        padding_right = 5,
      },
      label = {
        style = "Bold",
        size = 14.0,
        y_offset = 1,
        padding_left = 0,
        padding_right = 5,
      },
    },
    group_paddings = 8,
  },
}

local profile_name = resolve_profile()
local active_profile = profiles[profile_name]

return {
  profile = profile_name,
  profiles = profiles,
  bar = active_profile.bar,
  defaults = active_profile.defaults,
  paddings = 5,
  group_paddings = active_profile.group_paddings,
  icons = "NerdFont",
  font = font,
  icon_font = font.text,
  inspired_icon_font = font.text,
}
