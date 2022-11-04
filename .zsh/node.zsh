# node
# nvmコマンドを使用したときのみnvm.shをロードするようにする。
# https://qiita.com/uasi/items/80865646607b966aedc8
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && [ -z "$(ls $NVM_DIR)" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
NODE_VER=`cat ${NVM_DIR}/alias/default`
NODE_DIR=${NVM_DIR}/versions/node/${NODE_VER}
export NODE_BIN=${NODE_DIR}/bin
PATH=${NODE_BIN}:$PATH
MANPATH=${NODE_DIR}/share/man:$MANPATH
export NODE_PATH=${NODE_DIR}/lib/node_modules
NODE_PATH=${NODE_PATH:A}
function nvm() {
    unset -f nvm
    source "${NVM_DIR:-$HOME/.nvm}/nvm.sh"
    nvm "$@"
}

