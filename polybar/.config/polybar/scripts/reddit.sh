#!/usr/bin/env sh

URL=$(pass reddit/inbox-unread-url)
USERAGENT="polybar-scripts/notification-reddit:v1.0 u/reddituser"

notifications=$(curl -sf --user-agent "$USERAGENT" "$URL" | jq '.["data"]["children"] | length')

if [ -n "$notifications" ] && [ "$notifications" -gt 0 ]; then
    echo "$notifications"
else
    echo "0"
fi
