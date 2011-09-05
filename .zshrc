# Created by newuser for 4.3.12


source ~/dotfiles/.zsh/auto-fu.zsh
# auto-fuを初期化する。
zle-line-init() {
    auto-fu-init
}
zle -N zle-line-init
zle -N zle-keymap-select auto-fu-zle-keymap-select

# auto-fuをカスタマイズする。
## Enterを押したときは自動補完された部分を利用しない。
afu+cancel-and-accept-line() {
    ((afu_in_p == 1)) && { afu_in_p=0; BUFFER="$buffer_cur" }
    zle afu+accept-line
}
zle -N afu+cancel-and-accept-line
bindkey -M afu "^M" afu+cancel-and-accept-line



# キーバインド設定
bindkey -e



# 指定したコマンド名がなく、ディレクトリ名と一致した場合 cd する
setopt auto_cd
# cdで移動してもpushdと同じようにディレクトリスタックに追加する。
setopt auto_pushd
# カレントディレクトリ中に指定されたディレクトリが見つからなかった場合に
# 移動先を検索するリスト。
cdpath=(~)
## ディレクトリが変わったらディレクトリスタックを表示。
chpwd_functions=($chpwd_functions dirs)



# ヒストリ
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=$HISTSIZE
# ヒストリファイルにコマンドラインだけではなく実行時刻と実行時間も保存する。
setopt extended_history
# 直前と同じコマンドラインはヒストリに追加しない
setopt hist_ignore_dups
# コマンドラインの先頭がスペースで始まる場合ヒストリに追加しない
setopt hist_ignore_space
# すぐにヒストリファイルに追記する。
setopt inc_append_history
# シェルのプロセスごとに履歴を共有
setopt share_history
# Ctrl+S/Ctrl+Q によるフロー制御を使わないようにする
setopt NO_flow_control



# 色を使う
setopt prompt_subst
# PROMPT内で「%」文字から始まる置換機能を有効にする。
setopt prompt_percent
#コピペの時rpromptを非表示する
setopt transient_rprompt
## 256色生成用便利関数
### red: 0-5
### green: 0-5
### blue: 0-5
color256()
{
    local red=$1; shift
    local green=$2; shift
    local blue=$3; shift

    echo -n $[$red * 36 + $green * 6 + $blue + 16]
}

fg256()
{
    echo -n $'\e[38;5;'$(color256 "$@")"m"
}

bg256()
{
    echo -n $'\e[48;5;'$(color256 "$@")"m"
}

## プロンプトの作成
### ↓のようにする。
###   -(user@debian)-(0)-<2011/09/01 00:54>------------------------------[/home/user]-
###   -[84](0)%                                                                   [~]

## バージョン管理システムの情報も表示する
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats \
    '(%{%F{white}%K{green}%}%s%{%f%k%})-[%{%F{white}%K{blue}%}%b%{%f%k%}]'
zstyle ':vcs_info:*' actionformats \
    '(%{%F{white}%K{green}%}%s%{%f%k%})-[%{%F{white}%K{blue}%}%b%{%f%k%}|%{%F{white}%K{red}%}%a%{%f%k%}]'
### プロンプトバーの左側
###   %{%B%}...%{%b%}: 「...」を太字にする。
###   %{%F{cyan}%}...%{%f%}: 「...」をシアン色の文字にする。
###   %n: ユーザ名
###   %m: ホスト名（完全なホスト名ではなくて短いホスト名）
###   %{%B%F{white}%(?.%K{green}.%K{red})%}%?%{%f%k%b%}:
###                           最後に実行したコマンドが正常終了していれば
###                           太字で白文字で緑背景にして異常終了していれば
###                           太字で白文字で赤背景にする。
###   %{%F{white}%}: 白文字にする。
###     %(x.true-text.false-text): xが真のときはtrue-textになり
###                                偽のときはfalse-textになる。
###       ?: 最後に実行したコマンドの終了ステータスが0のときに真になる。
###       %K{green}: 緑景色にする。
###       %K{red}: 赤景色を赤にする。
###   %?: 最後に実行したコマンドの終了ステータス
###   %{%k%}: 背景色を元に戻す。
###   %{%f%}: 文字の色を元に戻す。
###   %{%b%}: 太字を元に戻す。
###   %D{%Y/%m/%d %H:%M}: 日付。「年/月/日 時:分」というフォーマット。
prompt_bar_left_self="(%{%B%}%n%{%b%}%{%F{cyan}%}@%{%f%}%{%B%}%m%{%b%})"
prompt_bar_left_status="(%{%B%F{white}%(?.%K{green}.%K{red})%}%?%{%k%f%b%})"
prompt_bar_left_date="<%{%B%}%D{%Y/%m/%d %H:%M}%{%b%}>"
prompt_bar_left="-${prompt_bar_left_self}-${prompt_bar_left_status}-${prompt_bar_left_date}-"
### プロンプトバーの右側
###   %{%B%K{magenta}%F{white}%}...%{%f%k%b%}:
###       「...」を太字のマジェンタ背景の白文字にする。
###   %d: カレントディレクトリのフルパス（省略しない）
prompt_bar_right="-[%{%B%K{magenta}%F{white}%}%d%{%f%k%b%}]-"

### 2行目左にでるプロンプト。
###   %h: ヒストリ数。
###   %(1j,(%j),): 実行中のジョブ数が1つ以上ある場合だけ「(%j)」を表示。
###     %j: 実行中のジョブ数。
###   %{%B%}...%{%b%}: 「...」を太字にする。
###   %#: 一般ユーザなら「%」、rootユーザなら「#」になる。
prompt_left="-[%h]%(1j,(%j),)%{%B%}%#%{%b%} "
## プロンプトフォーマットを展開した後の文字数を返す。
## 日本語未対応。
count_prompt_characters()
{
    # print:
    #   -P: プロンプトフォーマットを展開する。
    #   -n: 改行をつけない。
    # sed:
    #   -e $'s/\e\[[0-9;]*m//g': ANSIエスケープシーケンスを削除。
    print -n -P -- "$1" | sed -e $'s/\e\[[0-9;]*m//g' | wc -m
}

## プロンプトを更新する。
update_prompt()
{
    # プロンプトバーの左側の文字数を数える。
    # 左側では最後に実行したコマンドの終了ステータスを使って
    # いるのでこれは一番最初に実行しなければいけない。そうし
    # ないと、最後に実行したコマンドの終了ステータスが消えて
    # しまう。
    local bar_left_length=$(count_prompt_characters "$prompt_bar_left")
    # プロンプトバーに使える残り文字を計算する。
    # $COLUMNSにはターミナルの横幅が入っている。
    local bar_rest_length=$[COLUMNS - bar_left_length]

    local bar_left="$prompt_bar_left"
    # パスに展開される「%d」を削除。
    local bar_right_without_path="${prompt_bar_right:s/%d//}"
    # 「%d」を抜いた文字数を計算する。
    local bar_right_without_path_length=$(count_prompt_characters "$bar_right_without_path")
    # パスの最大長を計算する。
    #   $[...]: 「...」を算術演算した結果で展開する。
    local max_path_length=$[bar_rest_length - bar_right_without_path_length]
    # パスに展開される「%d」に最大文字数制限をつける。
    #   %d -> %(C,%${max_path_length}<...<%d%<<,)
    #     %(x,true-text,false-text):
    #         xが真のときはtrue-textになり偽のときはfalse-textになる。
    #         ここでは、「%N<...<%d%<<」の効果をこの範囲だけに限定させる
    #         ために用いているだけなので、xは必ず真になる条件を指定している。
    #       C: 現在の絶対パスが/以下にあると真。なので必ず真になる。
    #       %${max_path_length}<...<%d%<<:
    #          「%d」が「${max_path_length}」カラムより長かったら、
    #          長い分を削除して「...」にする。最終的に「...」も含めて
    #          「${max_path_length}」カラムより長くなることはない。
    bar_right=${prompt_bar_right:s/%d/%(C,%${max_path_length}<...<%d%<<,)/}
    # 「${bar_rest_length}」文字分の「-」を作っている。
    # どうせ後で切り詰めるので十分に長い文字列を作っているだけ。
    # 文字数はざっくり。
    local separator="${(l:${bar_rest_length}::-:)}"
    # プロンプトバー全体を「${bar_rest_length}」カラム分にする。
    #   %${bar_rest_length}<<...%<<:
    #     「...」を最大で「${bar_rest_length}」カラムにする。
    bar_right="%${bar_rest_length}<<${separator}${bar_right}%<<"

    # プロンプトバーと左プロンプトを設定
    #   "${bar_left}${bar_right}": プロンプトバー
    #   $'\n': 改行
    #   "${prompt_left}": 2行目左のプロンプト
    PROMPT="${bar_left}${bar_right}"$'\n'"${prompt_left}"
    # 右プロンプト
    #   %{%B%F{white}%K{green}}...%{%k%f%b%}:
    #       「...」を太字で緑背景の白文字にする。
    #   %~: カレントディレクトリのフルパス（可能なら「~」で省略する）
    RPROMPT="[%{%B%F{white}%K{magenta}%}%~%{%k%f%b%}]"

    # バージョン管理システムの情報を取得する。
    LANG=C vcs_info >&/dev/null
    # バージョン管理システムの情報があったら右プロンプトに表示する。
    if [ -n "$vcs_info_msg_0_" ]; then
    RPROMPT="${vcs_info_msg_0_}-${RPROMPT}"
    fi
}
## コマンド実行前に呼び出されるフック。
precmd_functions=($precmd_functions update_prompt)


### 非端末プロセスなら終了
#[ $#PROMPT -eq 0 -o $#TERM -eq 0 ] && return
## PROMPT, RPROMPT
#local GREEN=$'%{\e[1;32m%}'
#local BLUE=$'%{\e[1;34m%}'
#local DEFAULT=$'%{\e[00;m%}'
#
#PROMPT=$BULE'[${USER}@${HOSTNAME}] %(!.#.$) '$DEFAULT
#RPROMPT=$GREEN'[%~]'$DEFAULT



### Autocomplete
autoload -U compinit
#compinit -u
compinit

## 補完方法毎にグループ化する。
### 補完方法の表示方法
###   %B...%b: 「...」を太字にする。
###   %d: 補完方法のラベル
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*' group-name ''

## 補完侯補をメニューから選択する。
### select=2: 補完候補を一覧から選択する。
###           ただし、補完候補が2つ以上なければすぐに補完する。
zstyle ':completion:*:default' menu select=2

## 補完候補に色を付ける。
### "": 空文字列はデフォルト値を使うという意味。
zstyle ':completion:*:default' list-colors ""

## 補完候補がなければより曖昧に候補を探す。
### m:{a-z}={A-Z}: 小文字を大文字に変えたものでも補完する。
### r:|[._-]=*: 「.」「_」「-」の前にワイルドカード「*」があるものとして補完する。
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} r:|[._-]=*'
## 補完方法の設定。指定した順番に実行する。
### _oldlist 前回の補完結果を再利用する。
### _complete: 補完する。
### _match: globを展開しないで候補の一覧から補完する。
### _history: ヒストリのコマンドも補完候補とする。
### _ignored: 補完候補にださないと指定したものも補完候補とする。
### _approximate: 似ている補完候補も補完候補とする。
### _prefix: カーソル以降を無視してカーソル位置までで補完する。
zstyle ':completion:*' completer \
    _oldlist _complete _match _history _ignored _approximate _prefix

## 補完候補をキャッシュする。
zstyle ':completion:*' use-cache yes
## 詳細な情報を使う。
zstyle ':completion:*' verbose yes
## sudo時にはsudo用のパスも使う。
#zstyle ':completion:sudo:*' environ PATH="$SUDO_PATH:$PATH"

## カーソル位置で補完する。
setopt complete_in_word
## globを展開しないで候補の一覧から補完する。
setopt glob_complete
## 補完時にヒストリを自動的に展開する。
setopt hist_expand
# ファイル名の展開で、辞書順ではなく数値的にソートされるようになる
setopt numeric_glob_sort
# ビープ音を鳴らさないようにする
setopt no_beep
# コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt magic_equal_subst
# ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
setopt mark_dirs
# ファイル名で #, ~, ^ の 3 文字を正規表現として扱う
setopt extended_glob
# 内部コマンド jobs の出力をデフォルトで jobs -l にする
setopt long_list_jobs
# ログイン・ログアウト
## 全てのユーザのログイン・ログアウトを監視する。
watch="all"
## ログイン時にはすぐに表示する。
log
# Ctrl+D では終了しないようになる（exit, logout などを使う）
setopt ignore_eof
# 単語
## 「/」も単語区切りとみなす。
WORDCHARS=${WORDCHARS:s,/,,}

# alias
## ページャーを使いやすくする。
### grep -r def *.rb L -> grep -r def *.rb |& lv
alias -g L="|& $PAGER"
## grepを使いやすくする。
alias -g G='| grep'
## 後はおまけ。
alias -g H='| head'
alias -g T='| tail'
alias -g S='| sed'

## 完全に削除。
alias rr="command rm -rf"
## ファイル操作を確認する。
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
## pushd/popdのショートカット。
alias pd="pushd"
alias po="popd"

alias la="ls -lhAF --color=auto"
alias ps="ps -fU$(whoami) --forest"

# ウィンドウタイトル
## 実行中のコマンドとユーザ名とホスト名とカレントディレクトリを表示。
update_title() {
    local command_line=
    typeset -a command_line
    command_line=${(z)2}
    local command=
    if [ ${(t)command_line} = "array-local" ]; then
    command="$command_line[1]"
    else
    command="$2"
    fi
    print -n -P "\e]2;"
    echo -n "(${command})"
    print -n -P " %n@%m:%~\a"
}
## X環境上でだけウィンドウタイトルを変える。
if [ -n "$DISPLAY" ]; then
    preexec_functions=($preexec_functions update_title)
fi

