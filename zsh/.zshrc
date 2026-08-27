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
zstyle ':z4h:bindkey' keyboard  'mac'

# Don't start tmux.
zstyle ':z4h:' start-tmux       no

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'yes'

# Make tab in fzf actually do recursive copmletion
zstyle ':z4h:fzf-complete' fzf-bindings tab:repeat

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
# zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

# Clone additional Git repositories from GitHub.
#
# This doesn't do anything apart from cloning the repository and keeping it
# up-to-date. Cloned files can be used after `z4h init`. This is just an
# example. If you don't plan to use Oh My Zsh, delete this line.
# I don't use ohmyzsh
# z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
#
#
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
# z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file
# z4h load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # load a plugin

# Define key bindings.
z4h bindkey undo Ctrl+/   Shift+Tab  # undo the last command line change
z4h bindkey redo Option+/            # redo the last undone command line change

z4h bindkey z4h-cd-back    Shift+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Shift+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Shift+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Shift+Down   # cd into a child directory

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Define aliases.
alias tree='tree -a -I .git'

# --- My custom aliases
alias mb=micromamba

# replace ls with eza
alias ls='eza -a --color=always --group-directories-first'                 # preferred listing
alias l='eza -al --color=always --group-directories-first --icons=always'  # long format
alias lst='eza -aT --color=always --group-directories-first'                # tree listing
alias l.="eza -a | grep -e '^\.'"                                          # show only dotfiles

# replace cat with bat
alias cat='bat'

# git aliases
alias gst='git status'
alias gco='git checkout'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcam='git commit -am'
alias gcb='git checkout -b'

# zsh4humans fzf config removes the preview, force it back in
alias fzf="fzf --style full \
    --preview 'fzf-preview.sh {}' --bind 'focus:transform-header:file --brief {}'"

# Check if Neovim is installed
if command -v nvim >/dev/null 2>&1; then
    alias vim='nvim'
fi

alias mb=micromamba

# Memes
alias lorem="curl https://gist.githubusercontent.com/eddie-atkinson/b502aae2dc358635faf67c51e95eab06/raw/f7b5c5be68a3daf9892167513840d435bef3e3bb/lorem.txt"

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A"

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu


# --- fzf configuration
# catppucin theme
export FZF_DEFAULT_OPTS=$'--color=fg:#c6d0f5,bg:#303446,hl:#e78284,fg+:#c6d0f5,bg+:#414559
  --color=hl+:#e78284,info:#ca9ee6,prompt:#ca9ee6,pointer:#f2d5cf
  --color=marker:#f5e0db,spinner:#f2d5cf,header:#e78284,border:#626880
  --color=gutter:#414559'


if command -v zoxide &> /dev/null
    then
        eval "$(zoxide init zsh --cmd j)"
fi


# Path modifications

path=(~/.zsh/scripts $path)

PATH="$PATH:$HOME/.emacs.d/bin"
PATH="$PATH:$HOME/.cargo/bin"
PATH="$PATH:$HOME/.local/bin"


# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

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


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

 # Nix
 if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
 fi
 # End Nix

# bun completions
[ -s "/Users/DAADAMS/.bun/_bun" ] && source "/Users/DAADAMS/.bun/_bun"

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/DAADAMS/.opam/opam-init/init.zsh' ]] || source '/Users/DAADAMS/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration

# Added by Antigravity
export PATH="/Users/DAADAMS/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity CLI installer
export PATH="/Users/DAADAMS/.local/bin:$PATH"

# Added by Antigravity IDE
export PATH="/Users/DAADAMS/.antigravity-ide/antigravity-ide/bin:$PATH"

# Added by the BaseRT installer
export PATH="/Users/DAADAMS/.basert:$PATH"
