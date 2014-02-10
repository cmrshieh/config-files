zstyle :compinstall filename '/home/jvanwink/.zshrc'
fpath=(/usr/local/share/zsh-completions $fpath)

source ~/.private_profile

autoload -Uz compinit && compinit
autoload -U colors && colors
autoload -U zmv

HISTFILE=~/.zhistory
HISTSIZE=25000
SAVEHIST=25000

setopt appendhistory
setopt completeinword
setopt extendedglob
setopt extendedhistory
setopt histexpiredupsfirst
setopt histfindnodups
setopt histignorealldups
setopt histignoredups
setopt histreduceblanks
setopt histverify
setopt incappendhistory
setopt sharehistory
unsetopt banghist
unsetopt cshjunkiehistory
unsetopt histallowclobber
unsetopt histbeep
unsetopt histignorespace
unsetopt histnofunctions
unsetopt histnostore
unsetopt histsavenodups

PS1="%{$fg[green]%}%n@%m:%{$fg[cyan]%}%~%{$reset_color%}%% "

for new_path in \
    "/usr/local/llvm-3.4/bin" \
    "/usr/local/opt/coreutils/libexec/gnubin" \
    "/usr/local/opt/gnu-sed/libexec/gnubin" \
    "/usr/local/opt/gnu-tar/libexec/gnubin" \
    "/sbin" \
    "/usr/sbin" \
    "/opt/local/bin" \
    "/usr/local/bin" \
    "$HOME/opt/bin" \
    "$HOME/bin" \
    "/usr/local/sbin" \
    "/opt/bin" \
    "/opt/local/lib/postgresql92/bin" \
    "/opt/X11/bin"; do
    if [ -d $new_path ] ; then
        PATH="$new_path:$PATH"
    fi
done

for new_man_path in \
    "/usr/local/opt/coreutils/libexec/gnuman" \
    "/usr/local/opt/gnu-sed/libexec/gnuman"; do
    if [ -d $new_man_path ] ; then
        MANPATH="$new_man_path:$MANPATH"
    fi
done


function act {
    source $HOME/.venv/$1/bin/activate
}

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export EDITOR='emacsclient'
export ALTERNATE_EDITOR='emacsnw'
export VISUAL=$EDITOR
export PAGER=less
export PYTHONIOENCODING="utf_8"

export LESS='-S -R'
export GREP_OPTIONS='--color=auto'
export LS_OPTIONS="-b --color=auto"
. ~/.ls_colors
export DEBEMAIL="justin.vanwinkle@gmail.com"
export DEBFULLNAME="Justin Van Winkle"
export TERM="xterm-256color"

alias ls="ls $LS_OPTIONS"
alias gf='find | grep -v \.pyc$ | grep'
alias fa='find | ack-grep'
alias ggf='git ls-files | grep'
alias gg='git grep'
alias loc='mdfind -name'
alias as="apt-cache search"
alias c-indent="gindent -nbad -bap -nbc -bbo -hnl -br -brs -c33 -cd33 -ncdb -ce -ci4 -cli0 -d0 -di1 -nfc1 -i4 -ip0 -l80 -lp -npcs -npsl -ncs -nsc -sob -nfca -cp33 -ss -ts8 -il1 -ppi 3 -brf"

#export CC=/usr/local/llvm-3.4/bin/clang
#export CXX=/usr/local/llvm-3.4/bin/clang++

export CRAM_VENV=~/.venv/cram
function cramit {
    cd ~/repos/cram
    source bin/activate.sh
}

function remssh {
    ssh-keygen -f ~/.ssh/known_hosts -R $1
}

function git-track {
    git checkout --track -b $1 origin/$1
}
