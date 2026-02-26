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

# Don't start tmux.
zstyle ':z4h:' start-tmux       no

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
# zstyle ':z4h:ssh:'   enable 'yes'
# zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
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
#path=(~/bin $path)

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

# Define aliases.
alias tree='tree -a -I .git'

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A"

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu




### my customisations
alias mb=micromamba

# User specific aliases and functions
if [ "$BASH_ENV" != "$HOME/.bashenv" ] && [ -r "$HOME/.bashenv" ]; then
  export BASH_ENV="$HOME/.bashenv"
fi

if [[ -f ~/.bash_aliases ]]; then
    . ~/.bash_aliases
fi

if command -v zoxide &> /dev/null
    then
        eval "$(zoxide init zsh --cmd j)"
fi



#color ls things
#alias ll='colorls -la'
#alias la='colorls -a'
#alias lsg='colorls --gs -l'
#alias ls='colorls'
if command -v eza &> /dev/null
    then
        alias ls='eza'
fi
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
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'
alias lorem="curl https://gist.githubusercontent.com/eddie-atkinson/b502aae2dc358635faf67c51e95eab06/raw/f7b5c5be68a3daf9892167513840d435bef3e3bb/lorem.txt"
alias c='clear'                             # c:            Clear terminal display
alias v='fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim'

# Set PATHS
PATH="$PATH:$HOME/.emacs.d/bin"
PATH="$PATH:$HOME/.cargo/bin"
PATH="$PATH:$HOME/.local/bin"

# Check if Neovim is installed
if command -v nvim >/dev/null 2>&1; then
    alias vim='nvim'
fi

# Variables
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#e5e9f0,bg:#3b4252,hl:#81a1c1
    --color=fg+:#e5e9f0,bg+:#3b4252,hl+:#81a1c1
    --color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac
    --color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b'

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git "
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
# export $FZF_CTRL_R_OPTS=""
# Setup fzf previews
export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --icons=always --tree --color=always {} | head -200'"


# fzf preview for tmux
export FZF_TMUX_OPTS=" -p90%,70% "

# I like the fzf default keybindings and settings but I want to keep z4h history widget
source <(fzf --zsh)
z4h bindkey z4h-fzf-history Ctrl+R


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

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
export MAMBA_EXE='/opt/homebrew/bin/micromamba';
export MAMBA_ROOT_PREFIX='/Users/DAADAMS/micromamba';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
#
if [ -d "/opt/asdf-vm" ]; then
    . /opt/asdf-vm/asdf.sh
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

GPG_TTY=$(tty)
export GPG_TTY


 # Nix
 if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
 fi
 # End Nix

# bun completions
[ -s "/Users/DAADAMS/.bun/_bun" ] && source "/Users/DAADAMS/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<



# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/DAADAMS/.opam/opam-init/init.zsh' ]] || source '/Users/DAADAMS/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration

PATH="/Users/DAADAMS/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/DAADAMS/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/DAADAMS/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/DAADAMS/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/DAADAMS/perl5"; export PERL_MM_OPT;


forgejo-push() {
  repo_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)") || return 1

  git remote add forgejo "ssh://git@code.dadams.org/dadams/${repo_name}" 2>/dev/null

  git push -u forgejo "$(git branch --show-current)"
}
