#!/bin/env bash

# Just template script to init tmux "projects"
# TODO add splits py PANE_ID

function init_session {
    SESSION_NAME=$1
    WINDOW_NAME=$2
    PANE=1
    if [[ -z "$2" ]]; then
        echo -e "ERROR: must specify window name to create session\nExample: init_session \"sess_name\" \"window_name\" \"command\""
    fi
    tmux has-session -t "$SESSION_NAME" 2>/dev/null
    if [ $? != 0 ]; then
        if [[ -n "$3" ]]; then
            tmux new-session -d -s "$SESSION_NAME" -n "$WINDOW_NAME" 
            tmux send-keys -t $SESSION_NAME:$WINDOW_NAME "$3" Enter
            return 0
        else
            tmux new-session -d -s "$SESSION_NAME" -n "$WINDOW_NAME"
            return 0 # New session created
        fi
    fi
    return 1 # Session already exists
}

function create_window {
    if [[ -z $1 ]]; then
        echo -e "ERROR: must specify window name\nExample: create_window \"window_name\" \"command\""
        exit
    fi
    WINDOW_NAME=$1
    PANE=1
    if [[ -n $2 ]]; then
        tmux new-window -t "$SESSION_NAME" -n "$WINDOW_NAME"
        tmux send-keys -t $SESSION_NAME:$WINDOW_NAME "$2" Enter
        return 1
    else
        tmux new-window -t "$SESSION_NAME" -n "$WINDOW_NAME"
        return 1
    fi
}

function vsplit {
    tmux split-window -v -t "$SESSION_NAME:$WINDOW_NAME.$PANE"
    PANE=$((PANE + 1))
    tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.$PANE "$1" Enter
    return $PANE
}

function hsplit {
    tmux split-window -h -t "$SESSION_NAME:$WINDOW_NAME.$PANE"
    PANE=$((PANE + 1))
    tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.$PANE "$1" Enter
    return $PANE
}

function select_window {
    if [[ -z $1 ]]; then
        echo -e "ERROR: must specify window name\nExample: select_window \"window_name\""
    fi
    SELECTED_WINDOW="$1"
}

function attach {
    if [[ -n $SELECTED_WINDOW ]]; then
        tmux attach-session -t "$SESSION_NAME:$SELECTED_WINDOW"
    else
        tmux attach-session -t "$SESSION_NAME"
    fi
}

function main {
    local sess="lua_dev"
    if init_session $sess "dev" "cd ~ && nvim"; then
        hsplit "htop"
        vsplit
        create_window "test" "cd ~ && ls -all"
        select_window "dev"
    fi
    attach
}

main
