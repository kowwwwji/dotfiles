# Ref:https://codeaid.jp/java-homebrew/
jdk() {
    version=$1
    export JAVA_HOME=$(/usr/libexec/java_home -v "$version");
    java -version
}