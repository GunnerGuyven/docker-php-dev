
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

if ( -not (Test-Path ~/.gitconfig)) {
  Write-Host -NoNewline "Didn't find .gitconfig in profile..."
  if ( Test-Path $context_mount/gitconfig ) {
    Write-Host " existing linked from context"
    ln -s $context_mount/gitconfig ~/.gitconfig
  }
  else {
    Write-Host "creating from scratch"
    touch $context_mount/gitconfig
    ln -s $context_mount/gitconfig ~/.gitconfig

  }
}

# prompt_quit

Write-Output "end of script"