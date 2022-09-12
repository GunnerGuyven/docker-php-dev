#!/bin/bash

# set -e #stop on error
# set -x #echo all lines to console

# context_mount=~/.mnt
context_mount=/mnt

if [ ! -f $context_mount/.noprompt ]; then
  echo "This container's context appears to be uninitialized."
  # echo "This is likely because you have not mounted a state volume to"
  # echo "'$HOME/.mnt'.  If you have, and this is your first use of this image"
  # echo "this message is safe to ignore, otherwise, you should abort"
  # echo "and mount context properly.  Failure to do this will result in"
  # echo "a lack of correctly saved settings after you stop this container"

  read -n1 -p "Perform initialization? [yN]" prompt
  if [[ ! ($prompt == 'y' || $prompt == 'Y') ]]; then
    echo "Aborting..."
    exit 1
  fi
  echo
  touch $context_mount/.noprompt
fi

if [ ! -f ~/.gitconfig ]; then
  if [ ! -f $context_mount/gitconfig ]; then
    touch $context_mount/gitconfig
    ln -s $context_mount/gitconfig ~/.gitconfig
    echo
    echo "Configuring git:"
    if [[ -n $DEFAULT_GIT_USER ]]; then
      echo "   name: $DEFAULT_GIT_USER"
      prompt="$DEFAULT_GIT_USER"
    else
      read -p "   name: " prompt
    fi
    if [[ -n "$prompt" ]]; then
      git config --global --add user.name "$prompt"
    fi
    if [[ -n $DEFAULT_GIT_EMAIL ]]; then
      echo "  email: $DEFAULT_GIT_EMAIL"
      prompt=$DEFAULT_GIT_EMAIL
    else
      read -p "  email: " prompt
    fi
    if [[ -n "$prompt" ]]; then
      git config --global --add user.email "$prompt"
    fi
  else
    ln -s $context_mount/gitconfig ~/.gitconfig
  fi
fi

if [ ! -d ~/.ssh ]; then
  if [ ! -d $context_mount/ssh ]; then
    mkdir $context_mount/ssh
  fi
  ln -s $context_mount/ssh ~/.ssh
fi

if [ ! -f ~/.ssh/config ]; then
echo
echo "Configuring ssh:"

cat > ~/.ssh/config << EOL
Host bitbucket.org
IdentityFile ~/.ssh/id_bitbucket_org_docker_php
EOL
ssh-keygen -N '' -f ~/.ssh/id_bitbucket_org_docker_php

echo
echo "Remember to register this public key with bitbucket:"
echo
cat ~/.ssh/id_bitbucket_org_docker_php.pub
echo

fi