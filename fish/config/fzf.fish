set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --no-messages'
set -gx FZF_DEFAULT_OPTS '--extended --cycle --select-1 --height 40% --reverse --border'
set -gx FZF_CTRL_R_OPTS "--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
