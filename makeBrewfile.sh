#!/bin/zsh

rm Brewfile;
brew bundle dump;
sort -u Brewfile -o Brewfile;
