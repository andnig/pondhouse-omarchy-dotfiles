# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return
# [[ -r /usr/share/blesh/ble.sh ]] && source /usr/share/blesh/ble.sh --noattach
export FZF_CTRL_R_COMMAND=

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value before
# we decide which rc file to source.
if [[ -f /etc/omarchy.conf ]]; then
  source /etc/omarchy.conf
  export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
else
  export OMARCHY_PATH=/usr/share/omarchy
fi
source "$OMARCHY_PATH/default/bash/rc"

# Pondhouse company defaults load after stock Omarchy.
[[ -r /usr/share/pondhouse/terminal/bashrc ]] && source /usr/share/pondhouse/terminal/bashrc
source ~/source/custom-functions

export PATH=$HOME/.npm-global/bin:$PATH
export PATH=$HOME/.local/share/mise/installs/node/latest/bin:$PATH
export PATH=$HOME/scripts:$PATH
set -o vi

source /usr/share/pondhouse/terminal/pondhouse-functions
source /usr/share/pondhouse/terminal/pondhouse-aliases

if [[ -n ${KITTY_INSTALLATION_DIR:-} && \
  -r $KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash ]]; then
  export KITTY_SHELL_INTEGRATION=${KITTY_SHELL_INTEGRATION:-no-cursor}
  source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
fi

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
alias oc2='opencode2'

# [[ ${BLE_VERSION-} ]] && ble-attach

_pondhouse_fzf_history() {
  local selected
  selected=$(
    {
      builtin fc -lnr -2147483648 | command sed $'s/^\t //'
      command tac "$HOME/.zsh_history" | command sed -E 's/^: [0-9]+:[0-9]+;//'
    } |
      LC_ALL=C command awk 'length && !seen[$0]++' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "--scheme=history --bind=ctrl-r:toggle-sort --highlight-line ${FZF_CTRL_R_OPTS-}") \
        FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) --query "$READLINE_LINE"
  ) || return

  [[ -n $selected ]] || return
  READLINE_LINE=$selected
  READLINE_POINT=${#READLINE_LINE}
}



if enable -f "$HOME/.local/lib/bash/libflyline.so" flyline 2>/dev/null; then
  flyline --load-zsh-history
  flyline set-style \
    recognised-command=green \
    unrecognised-command=red \
    inline-suggestion=color\(8\) \
    normal-text=white \
    secondary-text=color\(8\) \
    matching-char=bold
  flyline editor --show-inline-history true --auto-close-chars false --select-with-mouse false
  flyline suggestions --auto-suggest false --sort-order alphabetical
  flyline mouse --mode disabled --change-shape false
  flyline set-cursor --backend terminal --interpolate none
  flyline --show-animations false --enable-easter-eggs false
  flyline key bind Ctrl+r 'always=runBashCommand(_pondhouse_fzf_history)'
fi

# Optional: uncomment this block to launch or attach Herdr from local interactive terminals.
# if [[ $- == *i* && -z ${SSH_CONNECTION:-} && -z ${SSH_TTY:-} && \
#   -z ${TMUX:-} && ${HERDR_ENV:-0} != "1" && -z ${HERDR_SOCKET_PATH:-} ]] && \
#   command -v herdr >/dev/null 2>&1; then
#   herdr
# fi

# pnpm
export PNPM_HOME="/home/andreas/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# Pondhouse pnpm globals: /home/andreas/.local/share/pnpm/bin
if [[ -z ${PNPM_HOME:-} ]]; then export PNPM_HOME=/home/andreas/.local/share/pnpm; fi
case ":$PATH:" in
  *:/home/andreas/.local/share/pnpm/bin:*) ;;
  *) export PATH=/home/andreas/.local/share/pnpm/bin:"$PATH" ;;
esac
# Pondhouse pnpm globals end

# m365: use the personal-auth wrapper (company-docs tools/m365-personal-auth), not pnpm's bare launcher
[[ -x "$HOME/.local/bin/m365" ]] && m365() { "$HOME/.local/bin/m365" "$@"; }
