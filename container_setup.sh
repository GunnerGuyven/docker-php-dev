#!/bin/bash

# set -e #stop on error
# set -x #echo all lines to console

# context_mount=~/.mnt
context_mount=/mnt/context

: ${SSH_KEY_BITBUCKET:=id_docker_php_bitbucket}
: ${SSH_KEY_TERM:=id_docker_php_ssh_term}

prompt_quit() {
  show = ${1:-"Proceed? [yN]"}
  read -n1 -p $show prompt
  if [[ ! ($prompt == 'y' || $prompt == 'Y') ]]; then
    echo "Aborting..."
    echo
    exit 1
  fi
}

if [ ! -d $context_mount ]; then
  echo "This container requires a context mount for proper operation"
  echo "Please mount a volume to: $context_mount"
  prompt_quit
fi

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
    echo
    exit 1
  fi
  touch $context_mount/.noprompt
fi

# add gitconfig values
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

# create git ssh key
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
IdentityFile ~/.ssh/$SSH_KEY_BITBUCKET
EOL

if [ ! -f ~/.ssh/$SSH_KEY_BITBUCKET ]; then
  echo "Creating ssh key for git+bitbucket: "
  ssh-keygen -q -N '' -f ~/.ssh/$SSH_KEY_BITBUCKET
  echo "Key named: $SSH_KEY_BITBUCKET"
fi

echo
echo "Remember to register this public key with bitbucket:"
echo
cat ~/.ssh/$SSH_KEY_BITBUCKET.pub

fi

# create ssh keys for terminal access
if [ ! -f ~/.ssh/$SSH_KEY_TERM ]; then
  ssh-keygen -q -N '' -f ~/.ssh/$SSH_KEY_TERM
  cat ~/.ssh/$SSH_KEY_TERM.pub >> ~/.ssh/authorized_keys

  echo
  echo "Remember to register this private key on your client machine"
  echo "if you wish to connect to this container using ssh:"
  echo "~/.ssh/$SSH_KEY_TERM"
  
fi

echo
