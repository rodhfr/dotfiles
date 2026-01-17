function gtl --wraps="git log --oneline --graph -n 10 --decorate --pretty=format:'%C(yellow)%h%Creset %C(cyan)%d%Creset %s %C(green)(%cr)%Creset'" --description "alias gtl=git log --oneline --graph -n 10 --decorate --pretty=format:'%C(yellow)%h%Creset %C(cyan)%d%Creset %s %C(green)(%cr)%Creset'"
    git log --oneline --graph -n 10 --decorate --pretty=format:'%C(yellow)%h%Creset %C(cyan)%d%Creset %s %C(green)(%cr)%Creset' $argv
end
