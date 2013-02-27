
#!/bin/sh

cp _bash_profile .bash_profile

mkdir ~/bin
cp git-diff-wrapper ~/bin
chmod +x ~/bin/git-diff-wrapper

cp -a vimfiles ~/.vim
cp -a _vimrc ~/.vimrc
cp -a _gitconfig ~/.gitconfig
