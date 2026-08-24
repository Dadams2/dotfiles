local colors = require("colors")
local settings = require("settings")
local icon_map = require("helpers.icon_map")

local codex = sbar.add("item", "codex.usage", {
  position = "right",
  icon = {
    string = icon_map["Codex"],
    font = "sketchybar-app-font:Regular:16.0",
    color = colors.green,
  },
  label = {
    string = "--%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Semibold"],
      size = 12.0,
    },
  },
  update_freq = 60,
})

local command = [[
session_file="$(
  find "$HOME/.codex/sessions" -type f -name '*.jsonl' -print0 2>/dev/null |
    xargs -0 stat -f '%m %N' 2>/dev/null |
    sort -nr |
    head -n 1 |
    cut -d' ' -f2-
)"
[ -f "$session_file" ] || exit 0
tail -n 600 "$session_file" 2>/dev/null |
  jq -r '
    select(.type == "event_msg" and .payload.type == "token_count")
    | .payload.rate_limits.primary.used_percent
    | select(type == "number" and . >= 0 and . <= 100)
    | ((100 - .) | round | tostring) + "%"
  ' 2>/dev/null |
  tail -n 1
]]

local function update()
  sbar.exec(command, function(output)
    codex:set({ label = output:match("(%d+%%)") or "--%" })
  end)
end

codex:subscribe({ "routine", "forced", "system_woke" }, update)
update()
