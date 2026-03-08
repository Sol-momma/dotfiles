# エイリアス一覧

## Git エイリアス（`~/.gitconfig`）

### 基本操作

| エイリアス | 展開 | 使うシーン |
|---|---|---|
| `git co` | `git checkout` | ブランチ・ファイルの切り替え |
| `git br` | `git branch` | ブランチ一覧の確認・作成 |
| `git ci` | `git commit` | コミット（エディタが開く） |
| `git st` | `git status` | 変更状態の確認 |
| `git cm "msg"` | `git commit -m` | メッセージ付きでコミット |
| `git pl` | `git pull` | リモートの変更を取り込む |
| `git ps` | `git push` | リモートに push する |
| `git po` | `git push origin` | origin に push する |
| `git cb <name>` | `git checkout -b` | 新しいブランチを作って切り替え |
| `git unstage <file>` | `git reset HEAD --` | ステージングを取り消す |

### ログ・差分

| エイリアス | 展開 | 使うシーン |
|---|---|---|
| `git lg` | `git log --graph --pretty=... --all` | ブランチの分岐・合流をカラーグラフで確認 |

### Stash

| エイリアス | 展開 | 使うシーン |
|---|---|---|
| `git sl` | `stash list --pretty=...` | stash の一覧をいつ・どのブランチかで確認 |
| `git sd` | `stash show -p` | 直近の stash の中身を diff で確認 |
| `git su` | `stash -u` | 未追跡ファイル（新規作成）も含めて stash |
| `git ss` | `stash push --staged` | ステージ済みの変更だけを stash（作業中の他変更は残したい時） |
| `git sp` | `stash -p` | 一部の変更だけを選んで stash（インタラクティブ） |

### コミット修正・巻き戻し

| エイリアス | 展開 | 使うシーン |
|---|---|---|
| `git amend` | `commit --amend --no-edit` | コミット後にタイポを見つけた時、メッセージを変えずに変更を混ぜる |
| `git uncommit` | `reset --soft HEAD^` | コミットしたけどまだ修正があった時、ステージング状態に戻す |
| `git discard` | `reset --hard HEAD` | めちゃくちゃになった時、全変更を捨てて最後のコミットに戻す（⚠️ 戻せない） |

### AI

| エイリアス | 展開 | 使うシーン |
|---|---|---|
| `git aicommit` | Claude でコミットメッセージを日本語で生成（表示のみ） | `git add` 後にコミットメッセージの案を出してもらう |

---

## Fish abbr（`fish/config/abbr_ailiases.fish`）

### ファイル操作

| abbr | 展開 | 使うシーン |
|---|---|---|
| `ls` | `eza` | ファイル一覧（色付き・モダン表示） |
| `ll` | `eza -lah` | 隠しファイル含む詳細一覧 |
| `lt` | `eza --tree` | ツリー表示 |
| `lg` | `eza -lah --git` | git の変更状態も含めた詳細一覧 |
| `cat` | `bat` | シンタックスハイライト付きでファイル内容を見る |
| `rr` | `rm -r` | ディレクトリごと削除 |
| `rf` | `rm -rf` | 強制的に再帰削除（⚠️ 注意） |
| `mkd` | `mkdir -p` | 中間ディレクトリも含めて作成 |
| `o` | `open` | Finder やデフォルトアプリで開く |
| `pbc` | `pbcopy` | クリップボードにコピー |
| `pbp` | `pbpaste` | クリップボードから貼り付け |

### Git（短縮）

| abbr | 展開 | 使うシーン |
|---|---|---|
| `g` | `git` | git コマンドの省略 |
| `ga` | `git add` | ファイルをステージング |
| `ga.` | `git add .` | カレントディレクトリ全体をステージング |
| `gaa` | `git add --all` | 全変更をステージング |
| `gco` | `git checkout` | ブランチ・ファイルの切り替え |
| `gc` | `git commit` | コミット |
| `gcn` | `git commit -n` | フック無視でコミット |
| `gcl` | `git clone` | リポジトリをクローン |
| `gcm` | `git commit -m "..."` | メッセージ付きコミット（カーソル位置に入力） |
| `gcnm` | `git commit -n -m "..."` | フック無視でメッセージ付きコミット |
| `gcam` | `git commit --amend -m "..."` | 直前のコミットメッセージを修正 |
| `gcem` | `git commit --allow-empty -m "..."` | 空コミット（CI トリガーなど） |
| `gp` | `git push` | push |
| `gpo` | `git push origin` | origin に push |
| `gpf` | `git push --force-with-lease` | 安全な force push |
| `gpff` | `git push --force` | 強制 push（⚠️ 注意） |
| `gpl` | `git pull` | pull |
| `gf` | `git fetch` | fetch |
| `gsw` | `git switch` | ブランチ切り替え |
| `gswf` | `git switch feature/...` | feature ブランチに切り替え（名前入力） |
| `gsm` | `git switch main` or `master` | main/master に切り替え |
| `gpt` | `git push --tags` | タグを push |
| `gr` | `git rebase` | rebase |
| `gwt` | `git wt` | worktree 操作 |

### Git（`-c git` サブコマンド abbr）

`git` に続けて入力する省略形。

| abbr | 展開 | 使うシーン |
|---|---|---|
| `git a` | `add` | ステージング |
| `git aa` | `add -a` | 全変更をステージング |
| `git ap` | `add -p` | インタラクティブにステージング |
| `git cm` | `commit -m` | メッセージ付きコミット |
| `git cma` | `commit --amend -m` | コミットメッセージ修正 |
| `git b` | `branch` | ブランチ一覧 |
| `git bm` | `branch -m` | ブランチ名変更 |
| `git bu` | `rev-parse --abbrev-ref --symbolic-full-name @{u}` | 上流ブランチの確認 |
| `git bv` | `branch -vv` | ブランチ一覧（追跡情報付き） |
| `git br` | `browse` | ブラウザでリポジトリを開く |
| `git cl` | `clone` | クローン |
| `git cp` | `cherry-pick` | 特定コミットだけ取り込む |
| `git cpn` | `cherry-pick -n` | コミットせずに cherry-pick |
| `git f` | `fetch` | fetch |
| `git p` | `push` | push |
| `git pf` | `push --force-with-lease --force-if-includes` | 安全な force push |
| `git pushf` | `push --force-with-lease --force-if-includes` | 同上（長い形式） |
| `git rbm` | `rebase origin/main` | origin/main で rebase |
| `git rst` | `reset` | リセット |
| `git rs` | `restore` | ファイルを復元 |
| `git st` | `stash` | 変更を一時退避 |
| `git sts` | `status -s -uno` | 短形式ステータス（未追跡ファイル除外） |
| `git sm` | `submodule` | サブモジュール操作 |
| `git smu` | `submodule update --remote --init --recursive` | サブモジュールを再帰的に更新 |
| `git sma` | `submodule add` | サブモジュール追加 |
| `git sw` | `switch` | ブランチ切り替え |
| `git swc` | `switch -c` | 新ブランチ作成して切り替え |
| `git po` | `push origin` | origin に push |
| `git difff` | `diff --word-diff` | 単語レベルの差分確認 |
| `git cid` | `log -n 1 --format=%H` | 最新コミットの SHA を取得 |
| `git clb` | `clean-local-branches` | マージ済みローカルブランチを削除 |
| `git id` | `show -s --format=%H` | コミット SHA 表示 |
| `git co` | `checkout` | チェックアウト |
| `git cob` | `checkout -b` | 新ブランチ作成してチェックアウト |
| `git sha` | `rev-parse HEAD` | HEAD の SHA 表示 |
| `git pl` | `pull` | pull |
| `git pbr` | `browse-pr` | PR をブラウザで開く |

### GitHub CLI（gh）

| abbr | 展開 | 使うシーン |
|---|---|---|
| `ghp` | `gh poi` | PR 一覧を開く |
| `gh pco` | `pr checkout` | PR をローカルにチェックアウト |
| `gh pcr` | `pr create` | PR を作成 |
| `gh-fork-sync` | 全 fork リポジトリを sync | fork したリポジトリをまとめて upstream に追従 |

### Docker

| abbr | 展開 | 使うシーン |
|---|---|---|
| `do` | `docker container` | コンテナ操作の起点 |
| `dop` | `docker container ps` | 起動中コンテナ一覧 |
| `dob` | `docker container build` | イメージのビルド |
| `dor` | `docker container run --rm` | 使い捨てコンテナ実行 |
| `dox` | `docker container exec -it` | 起動中コンテナに入る |
| `dc` | `docker compose` | Compose 操作の起点 |
| `dcu` | `docker compose up` | サービス起動 |
| `dcub` | `docker compose up --build` | ビルドしてサービス起動 |
| `dcd` | `docker compose down` | サービス停止 |
| `dcr` | `docker compose restart` | サービス再起動 |

### Nix

| abbr | 展開 | 使うシーン |
|---|---|---|
| `ns` | `nix-shell` | Nix シェルに入る |
| `ngc` | `nix-collect-garbage` | 不要なパッケージを削除 |
| `nrn` | `nix run nixpkgs#...` | パッケージを一時的に実行 |
| `dv` | `devenv` | devenv で開発環境を操作 |

### AI ツール

| abbr | 展開 | 使うシーン |
|---|---|---|
| `cl` | `claude` | Claude Code を起動 |
| `cld` | `claude --dangerously-skip-permissions` | 確認スキップで Claude を起動 |
| `cldc` | `claude --dangerously-skip-permissions --continue` | 前のセッションを継続 |
| `clh` | `claude ... --model haiku` | 軽量・高速な Haiku で起動 |
| `clo` | `claude ... --model opus` | 最高性能の Opus で起動 |
| `cls` | `claude ... --model sonnet` | バランス型の Sonnet で起動 |
| `oc` | `opencode` | opencode を起動 |
| `cx` | `codex` | Codex CLI を起動 |
| `ca` | `cursor-agent` | Cursor Agent を起動 |

### エディタ

| abbr | 展開 | 使うシーン |
|---|---|---|
| `v` | `nvim` | Neovim でファイルを開く |
| `nv` | `nvim` | 同上 |
| `vim` | `nvim` | vim と打っても Neovim が起動する |
| `bash` | `bash --norc` | 設定なしの素の bash を起動 |

### ユーティリティ

| abbr | 展開 | 使うシーン |
|---|---|---|
| `clr` | `clear` | ターミナルをクリア |
| `sc` | `source ~/.config/fish/config.fish` | Fish の設定を即反映 |
| `sed` | `gsed` | GNU sed を使う（macOS 対応） |
| `python` | `python3` | python コマンドで python3 を呼ぶ |

---

> **Tip**: `sc` を実行すると Fish の abbr 変更が即反映されます。Git エイリアスはファイル保存後すぐに反映されます。
