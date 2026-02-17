#!/usr/bin/env sh

# sync maildir
# mbsync -a > /dev/null 2>&1

# Get unread count and capture the output along with any error messages
COUNT=$(mu find flag:unread and flag:new 2>&1)

# Check if there was an error message
if [[ $COUNT == "error: no matches for search expression" ]]; then
    echo "∅" # Return a smiley face
else
    # Count the number of lines in the output
    COUNT=$(echo "$COUNT" | wc -l)
    echo $COUNT
fi
