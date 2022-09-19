
$context_mount = "/mnt/context"

function prompt_quit {
  param (
    [string] $Prompt = "Proceed?"
  )
  $res = Read-Host "$Prompt [yN]"
  if ($res -notin "Y", "y" ) { exit 1 }
}

if ( -not (Test-Path $context_mount)) {
  Write-Host "This container requires a context mount for proper operation"
  Write-Host "Please mount a volume to: $context_mount"
  exit 1
  # prompt_quit "Proceed Anyway?"
}

function prompt_or_default {
  param(
    [string] $Prompt,
    [string] $Default
  )
  if ($Default) {
    Write-Host -NoNewline "${Prompt}: "
    Write-Host $Default -ForegroundColor DarkGray
    return $Default
  }
  return Read-Host $Prompt
}

if ( -not (Test-Path ~/.gitconfig)) {
  Write-Host -NoNewline "Setting up Git defaults..."
  if ( Test-Path $context_mount/gitconfig ) {
    Write-Host " linked from context" -ForegroundColor DarkGreen
    ln -s $context_mount/gitconfig ~/.gitconfig
  }
  else {
    Write-Host " creating" -ForegroundColor DarkYellow
    touch $context_mount/gitconfig
    ln -s $context_mount/gitconfig ~/.gitconfig
    $uname = prompt_or_default "   name" $env:DEFAULT_GIT_USER
    $email = prompt_or_default "  email" $env:DEFAULT_GIT_EMAIL
    git config --global user.name $uname
    git config --global user.email $email
  }
}
