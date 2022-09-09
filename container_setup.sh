if [ ! -f ~/.mnt/.noprompt ]; then
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
  touch ~/.mnt/.noprompt
fi

if [ ! -f ~/.gitconfig ]; then
  touch .mnt/gitconfig
  ln -s .mnt/gitconfig .gitconfig
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
fi

if [ ! -d ~/.ssh ]; then
  if [ ! -d ~/.mnt/ssh ]; then
    mkdir ~/.mnt/ssh
    ln -s .mnt/ssh ~/.ssh
  fi
fi

if [ ! -f ~/.ssh/config ]; then
echo
echo "Configuring ssh:"

cat > $HOME/.ssh/config << EOL
Host bitbucket.org
IdentityFile ~/.ssh/id_bitbucket_org_docker_php
EOL
ssh-keygen -N '' -f /home/dev/.ssh/id_bitbucket_org_docker_php

echo
echo "Remember to register this public key with bitbucket:"
echo
cat .ssh/id_bitbucket_org_docker_php.pub
echo

fi