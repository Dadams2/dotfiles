local colors = {
  black = 0xff181926,
  white = 0xffcad3f5,
  red = 0xffed8796,
  green = 0xffa6da95,
  blue = 0xff8aadf4,
  yellow = 0xffeed49f,
  orange = 0xfff5a97f,
  magenta = 0xffc6a0f6,
  pink = 0xfff5bde6,
  grey = 0xff939ab7,
  sky = 0xff7dc4e4,
  transparent = 0x00000000,

  surface = 0x66494d64,
  surface_alt = 0x9924273a,

-- this is where to set contrast for background
  bar = {
    -- bg = 0x8824273a,
    border = 0x00000000,
  },
  popup = {
    bg = 0xff1e1e2e,
    border = 0xffcad3f5,
  },
  bg0 = 0xff1e1e2e,
  bg1 = 0x66494d64,
  bg2 = 0x66494d64,

  icon_color = 0xffcad3f5,
  label_color = 0xffcad3f5,
  shadow_color = 0xff181926,
}

colors.item = {
  bg = colors.surface,
  current_space = colors.orange,
  front_app = colors.green,
  weather_moon = 0x667dc4e4,
  clock = colors.red,
}

colors.with_alpha = function(color, alpha)
  if alpha > 1.0 or alpha < 0.0 then
    return color
  end

  return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

return colors
