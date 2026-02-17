#!/usr/bin/env sh
# Define the path to your word list file
WORD_LIST=~/.tmux/random-words.txt
# Get the random word
RANDOM_WORD=$(shuf -n 1 $WORD_LIST)
# Create a new tmux session with the random word as the name
tmux new -s "$RANDOM_WORD" -d
# Attach to the newly created session
tmux switch-client -t "$RANDOM_WORD"
