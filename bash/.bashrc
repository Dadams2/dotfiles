# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific aliases and functions
if [ "$BASH_ENV" != "$HOME/.bashenv" ] && [ -r "$HOME/.bashenv" ]; then
  export BASH_ENV="$HOME/.bashenv"
fi

type module >/dev/null 2>&1 || . $BASH_ENV

if [[ -f ~/.bash_aliases ]]; then
    . ~/.bash_aliases
fi

if [[ -f ~/.bashrc_local ]]; then
    . ~/.bashrc_local
fi

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true

alias config='/usr/bin/git --git-dir=/home/dadams/.cfg/ --work-tree=/home/dadams'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


if [[ -n "$TMUX" ]]; then
  if [ "$SHELL" != "/bin/zsh" ]; then
    exec /bin/zsh
  fi
fi
