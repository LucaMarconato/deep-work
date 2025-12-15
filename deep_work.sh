#!/bin/bash

# Deep Work - A focused work session timer with ASCII art display
# Usage: ./deep_work.sh <time_string>
# Example: ./deep_work.sh 2h or ./deep_work.sh 2h30m

if [ -z "$1" ]; then
    echo "Usage: $0 <time_string>"
    echo "Example: $0 2h or $0 2h30m"
    exit 1
fi

TIME_STRING="$1"
SESSION_NAME="deep_work_$$"

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is required but not installed."
    echo "Install it with: brew install tmux"
    exit 1
fi

# Check if termdown is installed
if ! command -v termdown &> /dev/null; then
    echo "Error: termdown is required but not installed."
    echo "Install it with: pip install git+https://github.com/trehn/termdown"
    exit 1
fi

# Check if art library is installed, install if not
if ! python3 -c "import art" &> /dev/null; then
    echo "Installing art library..."
    pip install art
fi

# Generate ASCII art using Python art library
ASCII_ART=$(python3 << 'PYEOF'
from art import text2art
print(text2art("DEEP", font="block"))
print(text2art("WORK", font="block"))
print()
print(text2art("please do not interrupt", font="small"))
PYEOF
)

# Create a new tmux session
tmux new-session -d -s "$SESSION_NAME"

# Split the window horizontally (top and bottom)
tmux split-window -v -t "$SESSION_NAME"

# Select the top pane and display ASCII art
tmux select-pane -t "$SESSION_NAME:0.0"
tmux send-keys -t "$SESSION_NAME:0.0" "clear && cat << 'ASCIIEOF'
$ASCII_ART
ASCIIEOF
exec bash -c 'while true; do sleep 1000; done'" Enter

# Resize panes - make top pane smaller (just enough for ASCII art)
tmux resize-pane -t "$SESSION_NAME:0.0" -y 35

# Select the bottom pane and run the timer
tmux select-pane -t "$SESSION_NAME:0.1"

# Embedded timer script (from timer.py)
START_TIME=$(date +"%I:%M:%S")
tmux send-keys -t "$SESSION_NAME:0.1" "termdown -s --font-charset \" .oO#@\" \"$TIME_STRING\" && say 'the countdown is over!' && tmux kill-session -t \"$SESSION_NAME\" " Enter

# Attach to the session
tmux attach-session -t "$SESSION_NAME"
