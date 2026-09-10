# User Fish Configuration
# Ported from PowerShell Profile
source /usr/share/cachyos-fish-config/cachyos-config.fish 2>/dev/null || true

# Environment variables
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx EDITOR nvim
set -gx VISUAL nvim

# Ensure user binaries are prioritized in PATH
fish_add_path -m ~/.local/bin

# Cursor Style: Line / Beam cursor instead of block
set -g fish_cursor_default line
set -g fish_cursor_insert line
set -g fish_cursor_replace_one underscore
set -g fish_cursor_visual block

# ------------------------------------------------------------------------------
# Prompt & CLI Enhancements (Starship & Zoxide)
# ------------------------------------------------------------------------------
if type -q starship
    starship init fish | source
end

if type -q zoxide
    zoxide init fish | source
end

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------
# Navigation
alias up="cd .."
alias ...="cd ../.."
alias g.="cd .."
alias home="cd ~"
alias doc="cd ~/Documents"
alias docs="cd ~/Documents"
alias des="cd ~/Desktop"
alias dot="cd ~/.local/share/chezmoi"
alias dots="cd ~/.local/share/chezmoi"
alias local="cd ~/.local"

# General Utilities
alias agy="command agy --dangerously-skip-permissions"
alias q="exit"
alias :q="exit"
alias cls="clear"
alias vim="nvim"
alias vi="nvim"
alias nivm="nvim"
alias ep="nvim ~/.config/fish/config.fish"
alias editdot="nvim ~/.local/share/chezmoi"
alias rel="source ~/.config/fish/config.fish; and echo 'Fish config reloaded!'"
alias envs="echo \$PATH | tr ' ' '\n'"

# Modern CLI Replacements
if type -q bat
    alias cat="bat"
end
if type -q lsd
    alias ls="lsd"
    alias la="lsd -A"
    alias ll="lsd -la"
else
    alias la="ls -A"
    alias ll="ls -la"
end

# Chezmoi
alias st="chezmoi status"
alias chm="chezmoi managed"
alias chu="chezmoi update"
alias madd="chezmoi re-add"

# Git
alias gs="git status"
alias ga="git add ."
alias gp="git push"
alias lgall="git add . && git commit -m 'something' && git push -u origin master"

# Package Management (Arch / CachyOS)
alias pcheck="checkupdates; paru -Qua 2>/dev/null"
alias uall="paru -Syu"

# ------------------------------------------------------------------------------
# Functions Ported from PowerShell Profile
# ------------------------------------------------------------------------------
function mkcd --description "Create directory and enter it"
    mkdir -p $argv[1]; and cd $argv[1]
end

function cha --description "Add file to chezmoi"
    chezmoi add $argv
end

function cadd --description "Add file to chezmoi"
    chezmoi add $argv
end

function cadd-secret --description "Add encrypted secret to chezmoi"
    chezmoi add --encrypt $argv
end
alias cenc="cadd-secret"

function sec --description "Decrypt and view/copy secret"
    set -l file "new 1.txt"
    set -l clip 0
    for arg in $argv
        if test "$arg" = "-c" -o "$arg" = "--clip"
            set clip 1
        else
            set file $arg
        end
    end
    set -l target "$HOME/Documents/$file"
    if not test -f "$target"
        set target "$file"
    end
    set -l content (chezmoi cat "$target" 2>/dev/null)
    if test -z "$content"
        echo "Secret not found or unable to decrypt: $file"
        return 1
    end
    if test $clip -eq 1
        printf "%s" "$content" | xclip -selection clipboard
        echo "Decrypted secret copied to clipboard!"
    else
        printf "%s\n" "$content"
    end
end

function gtok --description "Extract GitHub token or secret to clipboard"
    set -l clip 0
    set -l raw 0
    for arg in $argv
        if test "$arg" = "-c" -o "$arg" = "--clip"
            set clip 1
        else if test "$arg" = "-r" -o "$arg" = "--raw"
            set raw 1
        end
    end
    set -l content (chezmoi cat "$HOME/Documents/new 1.txt" 2>/dev/null)
    if test -z "$content"
        set content (chezmoi cat "$HOME/.test-secret.txt" 2>/dev/null)
    end
    if test $raw -eq 1
        if test $clip -eq 1
            printf "%s" "$content" | xclip -selection clipboard
            echo "Full secret copied to clipboard!"
        else
            printf "%s\n" "$content"
        end
        return 0
    end
    set -l token (echo "$content" | grep -oE 'ghp_[a-zA-Z0-9]+' | head -n 1)
    if test -z "$token"
        set token "$content"
    end
    if test $clip -eq 1
        printf "%s" "$token" | xclip -selection clipboard
        echo "Token copied to clipboard!"
    else
        echo "$token"
    end
end

function dfor --description "Chezmoi forget deleted files"
    set -l deleted (chezmoi status | grep '^ D' | awk '{print $2}')
    for f in $deleted
        echo "Forgetting: $HOME/$f"
        chezmoi forget "$HOME/$f"
    end
end

function dp --description "Lazy commit and push dotfiles"
    echo "Starting automation..."
    cd ~/.local/share/chezmoi
    git add .
    git commit -m "added lazyily .files"
    git push -u origin master
    cd -
end

function dpush --description "Interactive commit and push dotfiles"
    echo "Starting automation..."
    cd ~/.local/share/chezmoi
    git add .
    read -P "Enter commit message: " msg
    if test -z "$msg"
        set msg "update dotfiles"
    end
    git commit -m "$msg"
    git push -u origin master
    cd -
end

function dall --description "Sync all changes, forget deleted, and push dotfiles"
    set -l msg $argv[1]
    echo "Changes done..."
    chezmoi status
    echo "Forgetting deleted files if any..."
    dfor
    echo "Re-adding modified files..."
    chezmoi re-add
    cd ~/.local/share/chezmoi
    git add .
    if test -z "$msg"
        git commit -m "added lazyily .files"
    else
        git commit -m "$msg"
    end
    git push -u origin master
    cd -
    echo "Dotfiles synchronized successfully!"
end

function gall --description "Commit and push dotfiles readme"
    cd ~/.local/share/chezmoi
    git add .
    git commit -m "for readme file"
    git push -u origin master
    cd -
end

function gc --description "Git commit with message"
    git commit -m "$argv"
end

function gcl --description "Git clone"
    git clone $argv
end

function gcom --description "Git add and commit"
    git add .
    git commit -m "$argv"
end

function lazyg --description "Git add, commit, and push"
    git add .
    git commit -m "$argv"
    git push
end

function gitall --description "Git add, commit, and push"
    git add .
    git commit -m "$argv"
    git push
end

# Clipboard & File Helpers
function cf --description "Copy file contents to clipboard"
    if test -f "$argv[1]"
        cat "$argv[1]" | xclip -selection clipboard
        echo "Copied $argv[1] to clipboard!"
    else
        echo "File does not exist: $argv[1]"
    end
end

function cpypath --description "Copy absolute path to clipboard"
    if test -e "$argv[1]"
        realpath "$argv[1]" | tr -d '\n' | xclip -selection clipboard
        echo "Path copied to clipboard!"
    else
        echo "Path does not exist: $argv[1]"
    end
end

function cpycmd --description "Run command and copy output to clipboard"
    eval "$argv" | xclip -selection clipboard
    echo "Command output copied to clipboard!"
end

function cdf --description "Fuzzy find directory or file parent and cd"
    set -l sel (find . -maxdepth 4 -not -path '*/.*' 2>/dev/null | fzf)
    if test -n "$sel"
        if test -d "$sel"
            cd "$sel"
        else
            cd (dirname "$sel")
        end
    end
end

function cdwhich --description "cd into directory of command binary"
    set -l p (type -p $argv[1] 2>/dev/null)
    if test -n "$p"
        cd (dirname "$p")
    else
        echo "Command not found: $argv[1]"
    end
end

function ff --description "Find file recursively by name"
    find . -iname "*$argv[1]*"
end

function fs --description "Grep search inside files"
    set -l pattern $argv[1]
    set -l path "."
    if test (count $argv) -ge 2
        set path $argv[2]
    end
    grep -rnI "$pattern" "$path"
end

function size --description "Calculate folder or file size"
    du -sh $argv[1]
end

# ------------------------------------------------------------------------------
# Keybindings
# ------------------------------------------------------------------------------
# Ctrl+b runs dall (mirrors Ctrl+Shift+b in PowerShell profile)
bind \cb "commandline -r 'dall'; commandline -f execute"
