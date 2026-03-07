# zsh → Fish 移行ガイド

## 概要

| 項目 | 移行前 | 移行後 |
|------|--------|--------|
| シェル | zsh + Zinit | Fish |
| プロンプト | Starship | pure-fish |
| エイリアス管理 | alias | abbr |

---

## 1. インストール

```sh
brew install fish

# pure-fish (プロンプト) は Fisher で入れる
brew install fisher
fisher install nickel-lang/pure

# よく使うツール (未インストールなら)
brew install zoxide fzf eza bat fd ripgrep direnv
```

デフォルトシェルを Fish に変更:

```sh
# Fish を許可シェルリストに追加
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells

# デフォルトシェルを変更
chsh -s /opt/homebrew/bin/fish
```

---

## 2. ディレクトリ構成

Fish の設定は `~/.config/fish/` 以下に置く。
zsh のように 1 ファイルに全部書かず、モジュール分割する。

```
~/.config/fish/
├── config.fish          # エントリポイント。config/ を source するだけ
├── config/
│   ├── path.fish        # PATH / 環境変数
│   ├── abbr.fish        # abbr (エイリアス)
│   ├── fzf.fish         # fzf 設定
│   ├── zoxide.fish      # zoxide 設定
│   └── tools.fish       # ツール別の初期化 (direnv, etc.)
└── functions/
    └── fish_greeting.fish  # 起動メッセージ (空にする)
```

---

## 3. config.fish (エントリポイント)

```fish
# ~/.config/fish/config.fish

# config/ 以下を全部読み込む
for f in ~/.config/fish/config/*.fish
    source $f
end
```

---

## 4. config/path.fish

zsh での `export PATH=...` は Fish では `fish_add_path` を使う。
`fish_add_path` は重複追加しないので冪等。

```fish
# Homebrew
fish_add_path -p /opt/homebrew/bin

# ユーザーローカル
fish_add_path $HOME/.local/bin

# Yarn
fish_add_path $HOME/.yarn/bin
fish_add_path $HOME/.config/yarn/global/node_modules/.bin

# Flutter
fish_add_path $HOME/dev/flutter/bin

# pyenv
set -gx PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin

# 環境変数
set -gx EDITOR nvim
set -gx MANPAGER "nvim -c ASMANPAGER -"
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx BAT_THEME TwoDark
```

---

## 5. config/tools.fish (ツール初期化)

```fish
# zoxide (cd の強化版)
zoxide init fish | source

# direnv
direnv hook fish | source

# pyenv
pyenv init - fish | source

# rbenv (使っていれば)
# rbenv init - fish | source

# NVM → fish-nvm プラグインで管理するか、fnm への乗り換えを推奨
# fisher install jorgebucaran/nvm.fish
# または
# brew install fnm && fnm env --use-on-cd | source

# Google Cloud SDK (パスが存在する場合だけ)
if test -d /opt/homebrew/share/google-cloud-sdk/bin
    fish_add_path /opt/homebrew/share/google-cloud-sdk/bin
end
```

> **NVM について**: Fish は bash/zsh の `source` 構文と非互換なので NVM がそのまま使えない。
> `fisher install jorgebucaran/nvm.fish` か `fnm`（Node Fast Manager）への乗り換えが推奨。
> fnm は Fish ネイティブ対応で高速。

```sh
# fnm を使う場合
brew install fnm
# → tools.fish に以下を追加
# fnm env --use-on-cd | source
```

---

## 6. config/abbr.fish (abbr によるエイリアス管理)

`alias` ではなく `abbr` を使う理由: コマンド展開がコマンドラインに表示されるので、
何が実行されるか一目でわかる。履歴にも展開後のコマンドが残る。

```fish
# ファイル操作
abbr -a ls  'eza'
abbr -a ll  'eza -lah'
abbr -a lt  'eza --tree'
abbr -a lg  'eza -lah --git'

# Git
abbr -a g   'lazygit'
abbr -a ga  'git add'
abbr -a gc  'git commit'
abbr -a gp  'git push'
abbr -a gs  'git status'

# cd の代わり (zoxide)
abbr -a z   'zoxide'

# その他
abbr -a v   'nvim'
abbr -a cat 'bat'
```

---

## 7. config/fzf.fish

```fish
set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --no-messages'
set -gx FZF_DEFAULT_OPTS '--extended --cycle --select-1 --height 40% --reverse --border'
set -gx FZF_CTRL_R_OPTS "--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
```

---

## 8. config/zoxide.fish

```fish
zoxide init fish | source
```

---

## 9. プロンプト: pure-fish

Starship をアンインストールして pure-fish を使う。
インストール後は設定不要でそのまま動く。

```sh
# Starship を削除
brew uninstall starship

# pure-fish を入れる (Fisher が必要)
brew install fisher
fisher install nickel-lang/pure
```

pure-fish のカスタマイズ例:

```fish
# config/pure.fish (必要なら作成)
set -g pure_show_jobs true
set -g pure_threshold_command_duration 5  # 5秒以上かかったコマンドは実行時間を表示
```

---

## 10. functions/fish_greeting.fish

起動メッセージを無効化:

```fish
function fish_greeting
end
```

---

## 11. zshrc から移行しない設定

以下は Fish 環境では不要・対応不可:

| zshrc の設定 | 理由 |
|---|---|
| `zinit` | Fish 専用プラグインマネージャ (Fisher) に置き換え |
| `autoload -Uz compinit` | Fish は補完が組み込み |
| `eval "$(starship init zsh)"` | pure-fish に置き換え |
| `GOOGLE_APPLICATION_CREDENTIALS="${PWD}/..."` | `$PWD` 依存は危険。プロジェクトごとに direnv で設定する |
| Conda の `shell.zsh hook` | `conda init fish` を実行する |

---

## 12. 移行後の確認チェックリスト

```sh
# Fish が起動するか
fish

# PATH が通っているか
echo $PATH

# zoxide が動くか
z --version

# abbr が展開されるか (ターミナルで ls と打つ)

# pure-fish がプロンプトに出るか
```

---

## 参考

- [Fish Documentation](https://fishshell.com/docs/current/)
- [pure-fish (nickel-lang/pure)](https://github.com/nickel-lang/pure)
- [Fisher](https://github.com/jorgebucaran/fisher)
- [fnm (Fast Node Manager)](https://github.com/Schniz/fnm)
- [jorgebucaran/nvm.fish](https://github.com/jorgebucaran/nvm.fish)
