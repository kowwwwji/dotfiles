function ssh_set_bgcolor() {
 case $1 in
   prd-* ) echo -e "\033]1337;SetProfile=Red\a" ;;
   stg-* ) echo -e "\033]1337;SetProfile=Blue\a" ;;
 esac
 # Ctrl+Cを押下時、背景色を元に戻す
 trap "echo -e '\033]1337;SetProfile=tmux\a'" 2
 # exitされた時、背景色を元に戻す
 trap "echo -e '\033]1337;SetProfile=tmux\a'" EXIT
 ssh $@
}
alias ssh='ssh_set_bgcolor'
