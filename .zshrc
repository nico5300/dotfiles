# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=500000
setopt autocd
unsetopt beep



# Highlight the current autocomplete option
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Better SSH/Rsync/SCP Autocomplete
zstyle ':completion:*:(scp|rsync):*' tag-order ' hosts:-ipaddr:ip\ address hosts:-host:host files'
zstyle ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Allow for autocomplete to be case insensitive
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
  '+l:|?=** r:|?=**'


zstyle :compinstall filename '/home/nico/.zshrc'

# Initialize the autocompletion
autoload -Uz compinit && compinit -i

# End of lines added by compinstall
# autoload -Uz compinit
# compinit
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
#bindkey -e


bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[5~" beginning-of-history
bindkey "^[[6~" end-of-history
bindkey "^[[3~" delete-char
bindkey "e[2~" quoted-insert
bindkey "e[5C" forward-word
bindkey "eOc" emacs-forward-word
bindkey "e[5D" backward-word
bindkey "eOd" emacs-backward-word
bindkey "ee[C" forward-word
bindkey "ee[D" backward-word
bindkey "^H" backward-delete-word
# for rxvt
bindkey "e[8~" end-of-line
bindkey "e[7~" beginning-of-line
# for non RH/Debian xterm, can't hurt for RH/DEbian xterm
bindkey "eOH" beginning-of-line
bindkey "eOF" end-of-line
# for freebsd console
bindkey "e[H" beginning-of-line
bindkey "e[F" end-of-line
# completion in the middle of a line
bindkey '^i' expand-or-complete-prefix


alias vim="nvim"
alias py="python"
alias tb="nc termbin.com 9999"
alias ampy0="ampy -p /dev/ttyUSB0"
alias cdback="cd \"$OLDPWD\""
alias stustaproxy="ssh -D 1337 -q -C -N stusta"
alias huginproxy="ssh -D 1337 -q -C -N hugin.stusta.mhn.de -J stusta"
alias psaproxy="ssh -D 1337 -q -C -N mypsavm"
alias serve="miniserve"
alias adminlist="vim ~/vorstand/ansible-private/accounts/users.yml"
alias popenstack="proxychains openstack"
alias s="ssh"
alias stustagit="GIT_SSH_COMMAND=\"ssh -J stusta\" git"
alias gitlog="git log --pretty=format:\"%h - %an: %s\" | head -n 20"
alias kleedocker="docker run -it -v ~/Bachelorarbeit/docker-mnt/:/mnt klee/klee"
alias optmypass="opt -aa -load=/home/nico/Studium/WS_21_22/Bachelorarbeit/PassesOutOfSource/build/MyPass/libMyPass.so"


export CC=clang
export CXX=clang++
export PYTHONSTARTUP=~/.pythonrc.py




# SSN Helpers
function ssn-id {
  if [[ -z "$1"  || -n "$2" ]]; then
    echo "Usage: ssn-id <id>"
    return 1
  fi

  local users="$HOME/vorstand/ansible-private/accounts/users.yml"
  # assume that a string starting with 0 is a member id
  # otherwise we assume to be searching for a name
  if [[ ${1:0:1} == "0" ]] ; then
    grep -A 2 $1 $users
  else
    grep -i -B 1 -A 1 $1 $users
  fi
}

function ssn-admins {
  if [[ -z "$1"  || -n "$2" ]]; then
    echo "Usage: ssn-admins <host>"
    return 1
  fi

  grep $1 "$HOME/vorstand/ansible-private/accounts/hosts.yml"
}

### Stuff from jj's zshrc ###
# test many host if they respond
function isup() {
        command -v fping >/dev/null || (echo "fping missing"; return)
        fping -c1 -t100 "$@" 2>&1 | \
                awk -F"[:/]" '/rcv/ {print $1, $5}' | \
                sed 's/ 1/ \x1b[32mup\x1b[0m/g;s/ 0/ \x1b[31mdown\x1b[0m/g'
}
#compdef isup ssh

# try pinging the host until it's reachable.
function tryping() {
        local timeout=1
        local interval=1
        local srv="$1"

        local i=0
        while true; do
                ping -q -W "$timeout" -c1 "$srv" > /dev/null
                if [ $? -eq 0 ]; then
                        notify-send "$srv is back!"
                        tput bel
                        echo -e "$srv is back!"
                        break;
                fi
                echo -en "\rtry $i "
                sleep "$interval"
                i=$((i + 1))
        done
}

# just return the fucking ip address
function getip() {
        local ip=$(dig +short "$1" | tail -n1)
        (test -n $ip && echo $ip) || return 1
}


transfer(){
    if [ $# -eq 0 ]; then
        echo "No arguments specified.\nUsage:\n  transfer <file|directory>\n  ... | transfer <file_name>">&2;
        return 1;
    fi;
    if tty -s; then 
        file="$1";
        file_name=$(basename "$file");
        if [ ! -e "$file" ]; then
            echo "$file: No such file or directory">&2;return 1;
        fi;
        if [ -d "$file" ]; then
            file_name="$file_name.zip" ,;
            (cd "$file"&&zip -r -q - .)|curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null,;
        else 
            cat "$file"|curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null;
        fi;
    else 
        file_name=$1;
        curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null;
    fi;
}




# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh/

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="jonathan"


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="dd.mm.yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git tmux sudo docker zsh-autosuggestions)
# plugins=(git tmux sudo docker zsh_reload)


# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source $ZSH/oh-my-zsh.sh

source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
