#!/bin/zsh

cd `dirname $0`

rm Brewfile;
brew bundle dump;
sort -u Brewfile -o Brewfile -r;
