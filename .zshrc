# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'pc'

# Start tmux if not already in tmux.
# zstyle ':z4h:' start-tmux command tmux -u new -A -D -t z4h

# Whether to move prompt to the bottom when zsh starts and on Ctrl+L.
zstyle ':z4h:' prompt-at-bottom 'no'

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'no'

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'no'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# SSH when connecting to these hosts.
zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

# Clone additional Git repositories from GitHub.
#
# This doesn't do anything apart from cloning the repository and keeping it
# up-to-date. Cloned files can be used after `z4h init`. This is just an
# example. If you don't plan to use Oh My Zsh, delete this line.
z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Extend PATH.
path=(~/bin $path)

# Export environment variables.
export GPG_TTY=$TTY

# Source additional local files if they exist.
z4h source ~/.env.zsh

# Use additional Git repositories pulled in with `z4h install`.
#
# This is just an example that you should delete. It does nothing useful.
z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file
z4h load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # load a plugin

# Define key bindings.
z4h bindkey z4h-backward-kill-word  Ctrl+Backspace     Ctrl+H
z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace

z4h bindkey undo Ctrl+/ Shift+Tab  # undo the last command line change
z4h bindkey redo Alt+/             # redo the last undone command line change

z4h bindkey z4h-cd-back    Alt+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Alt+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Alt+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Alt+Down   # cd into a child directory

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Init things that need to happen
eval "$(zoxide init zsh)"
[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh

# Define aliases.
alias tree='tree -a -I .git'

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
#color ls things
#alias ll='colorls -la'
#alias la='colorls -a'
#alias lsg='colorls --gs -l'
#alias ls='colorls'
alias ls='exa'
alias lst='ls --tree'
alias l='ls -l'
alias la='ls -a'
alias ll='ls -la'
alias lst='ls --tree'
alias worksync='rsync -auP work:~/Org/work ~/Org && rsync -auP ~/Org/work work:~/Org/'
alias roamsync='rsync -auP work:~/Roam ~/ && rsync -auP ~/Roam work:~/'
alias m='e --eval "(progn (magit-status) (delete-other-windows))"'
alias mt="m -t"
alias et="e -t"
alias kfast="pkill -f Fast"
alias restart-emacs="systemctl --user daemon-reload && systemctl --user restart emacs.service"
alias i3cheatsheet='egrep ^bind ~/.i3/config | cut -d '\'' '\'' -f 2- | sed '\''s/ /\t/'\'' | column -ts $'\''\t'\'' | pr -2 -w 145 -t | less'
alias zshc='vim ~/.zshrc'
alias tmuxc='vim ~/.tmux.conf'
alias vimc='vim ~/.config/nvim/init.vim'
alias j='z'
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'
alias lorem="curl https://gist.githubusercontent.com/eddie-atkinson/b502aae2dc358635faf67c51e95eab06/raw/f7b5c5be68a3daf9892167513840d435bef3e3bb/lorem.txt"
alias c='clear'                             # c:            Clear terminal display

# Set PATHS
PATH="$PATH:$HOME/.emacs.d/bin"
PATH="$PATH:$HOME/.cargo/bin"
PATH="$PATH:$HOME/.local/bin"

# Variables
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#e5e9f0,bg:#3b4252,hl:#81a1c1
    --color=fg+:#e5e9f0,bg+:#3b4252,hl+:#81a1c1
    --color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac
    --color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b'


# Add flags to existing aliases.
# alias ls="${aliases[ls]:-ls} -A"

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

# Custom functions
function cleandead {
   TMPDIR=/tmp
   DIR=$1
   DSTRING='WARNING: com.dugeo.util.swing.DeadlockDetector$DeadlockException'
   FILE=$(find $DIR -type f -printf "%T@ %p\n" | sort -n | tail -1 | cut -f2- -d" ")
   echo $FILE
   DATES=$(grep "$DSTRING" "$FILE" | awk '{print $1,$2}')
   echo $DATES

   cp -f "$FILE" $TMPDIR/tmpmove.tmp.0
   while read dt tm; do
      cp -f $TMPDIR/tmpmove.tmp.0 $TMPDIR/tmpmove.tmp.0.0
      VARONE=$(echo "$dt $tm")
      VARTWO=$(echo "$dt-$tm")
      echo $VARONE
      echo $VARTWO
      sed -ri "s/$VARONE java.lang./$VARTWO java.lang./g" $TMPDIR/tmpmove.tmp.0.0
      sed -ri "s/$VARONE//g" $TMPDIR/tmpmove.tmp.0.0
      mv -f $TMPDIR/tmpmove.tmp.0.0 $TMPDIR/tmpmove.tmp.0
   done < <(echo $DATES | xargs -n2)

   clean $FILE
}

# Cleans a stacktrace (does not work if the stacktrace still has a date/time)
function clean {
   FILE=$1
   TMPDIR=/tmp
   grep -vwE '^\s+at\s.*model\.property\..*$' $TMPDIR/tmpmove.tmp.0 >$TMPDIR/tmpmove.tmp.1
   grep -vwE '^.*Lambda\$[0123456789]+.*$' $TMPDIR/tmpmove.tmp.1 >$TMPDIR/tmpmove.tmp.2
   grep -vwE '^.*DebugIfSlowEvent.debugIfSlowOnEDT.*$' $TMPDIR/tmpmove.tmp.2 >$TMPDIR/tmpmove.tmp.3
   sed -r '/^\s+at\s.*$/ s/,\s/,/g' $TMPDIR/tmpmove.tmp.3 >$TMPDIR/tmpmove.tmp.4
   mv -f $TMPDIR/tmpmove.tmp.4 "$FILE"
   rm -f $TMPDIR/tmpmove.tmp.0 $TMPDIR/tmpmove.tmp.1 $TMPDIR/tmpmove.tmp.2 $TMPDIR/tmpmove.tmp.3 $TMPDIR/tmpmove.tmp.4
}

function wsync {
  rsync -aP work:$1 .
}


function save_workspace {
   i3-save-tree --workspace $1 > ~/.config/i3/workspace_$1.json
sed -i 's|^\(\s*\)// "|\1"|g; /^\s*\/\//d' ~/.config/i3/workspace_$1.json
   echo "Make sure to manually edit ~/.config/i3/workspace-$1.json"
}
