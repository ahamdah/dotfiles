# Ahmad Fahad 👨‍🎓

---
# Windows <div style="color: #e95420">subsystem configuration</div>
#### Installing **[<u>Ubuntu</u>](https://apps.microsoft.com/store/detail/ubuntu/9PDXGNCFSCZV)**.

## Terminal

#### Windows Terminal emulator **[install](https://www.microsoft.com/store/productId/9N0DX20HK701)** .


![ ](https://media.discordapp.net/attachments/675114478949498921/946599513924194344/unknown.png?width=1214&height=683)

##### Theme install ( **[Dracula Theme](https://draculatheme.com/windows-terminal)**)


## Shell
#### Installing **[<u>z-shell</u>](https://gist.github.com/derhuerst/12a1558a4b408b3b2b6e)**.

```shell
sudo apt update
sudo apt upgrade
sudo apt install zsh -y
```
#### Installing [Oh-My-Zsh](https://ohmyz.sh/) .
oh my Zsh is tool i used it to manage Zsh configuration and its provide  bundled with plugins and themes...

--- 

#### z-shell Theme

i am using **`re5et`** theme _(!That Theme from oh_my_zsh)_.

to install it put _**`ZSH_THEME="re5et"`**_ in _~/.zshrc file_.


![ ](https://media.discordapp.net/attachments/675114478949498921/946597393443483648/unknown.png?width=1214&height=683)

---
### z-shel plugin 

| My Plugin        |
| ------------- |
|git|
| zsh-syntax-highlighting    |
| zsh-autosuggestions  |
|  sudo |
|web-search|   
|copyfile|
|tmux|
|copybuffer|
|dirhistory|
|vscode|
|history|

There more plugin in oh-my-zsh we can use it but thats plugin i need it .
___

and i have some alias i use it and some bindkey.

## zsh configuration 

put that configuration in _~/.zshrc file_

```
#Path
export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"

#Themes 
ZSH_THEME="re5et"


zstyle ':omz:update' mode reminder  # just remind me to update when it's time


DISABLE_LS_COLORS="true"

DISABLE_AUTO_TITLE="true"

plugins=(
    git 
    zsh-syntax-highlighting
    zsh-autosuggestions
    sudo
    web-search
    copyfile
    tmux
    copybuffer
    dirhistory
    vscode
    history
)
source $ZSH/oh-my-zsh.sh

# User configuration

#export MANPATH="/usr/local/man:$MANPATH"

export LANG=en_US.UTF-8

# Example aliases
alias zshconfig="n ~/.zshrc"
alias ohmyzsh="n ~/.oh-my-zsh"
alias n="nvim"
alias start="explorer.exe .";


bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word


#https://stackoverflow.com/questions/5407916/zsh-zle-shift-selection


r-delregion() {
  if ((REGION_ACTIVE)) then
     zle kill-region
  else 
    local widget_name=$1
    shift
    zle $widget_name -- $@
  fi
}

r-deselect() {
  ((REGION_ACTIVE = 0))
  local widget_name=$1
  shift
  zle $widget_name -- $@
}

r-select() {
  ((REGION_ACTIVE)) || zle set-mark-command
  local widget_name=$1
  shift
  zle $widget_name -- $@
}

for key     kcap   seq        mode   widget (
    sleft   kLFT   $'\e[1;2D' select   backward-char
    sright  kRIT   $'\e[1;2C' select   forward-char
    sup     kri    $'\e[1;2A' select   up-line-or-history
    sdown   kind   $'\e[1;2B' select   down-line-or-history

    send    kEND   $'\E[1;2F' select   end-of-line
    send2   x      $'\E[4;2~' select   end-of-line

    shome   kHOM   $'\E[1;2H' select   beginning-of-line
    shome2  x      $'\E[1;2~' select   beginning-of-line

    left    kcub1  $'\EOD'    deselect backward-char
    right   kcuf1  $'\EOC'    deselect forward-char

    end     kend   $'\EOF'    deselect end-of-line
    end2    x      $'\E4~'    deselect end-of-line

    home    khome  $'\EOH'    deselect beginning-of-line
    home2   x      $'\E1~'    deselect beginning-of-line

    csleft  x      $'\E[1;6D' select   backward-word
    csright x      $'\E[1;6C' select   forward-word
    csend   x      $'\E[1;6F' select   end-of-line
    cshome  x      $'\E[1;6H' select   beginning-of-line

    cleft   x      $'\E[1;5D' deselect backward-word
    cright  x      $'\E[1;5C' deselect forward-word

    del     kdch1   $'\E[3~'  delregion delete-char
    bs      x       $'^?'     delregion backward-delete-char

  ) {
  eval "key-$key() {
    r-$mode $widget \$@
  }"
  zle -N key-$key
  bindkey ${terminfo[$kcap]-$seq} key-$key
}

```
