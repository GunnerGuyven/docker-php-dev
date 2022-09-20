

# Set-PSDebug -Trace 1

#region settings
$context_mount = "/mnt/context"
$ssh_key_bitbucket = $env:SSH_KEY_BITBUCKET ?? "id_docker_php_bitbucket"
$ssh_key_term = $env:SSH_KEY_TERM ?? "id_docker_php_ssh_term"
#endregion

#region prompt function helpers

enum Step {
  Git
  SSH
  SSHConfig
  SSHConfigGitKey
}
$_stepPromptValues = @(
  "Setting up Git defaults"
  "Adding SSH context"
  "Missing SSH config"
  "  And Git Key"
)
$_stepPromptValuesMaxLen = ($_stepPromptValues | Measure-Object -Maximum -Property Length).Maximum
function step_prompt {
  param (
    [Parameter(ValueFromPipeline = $true)][Step] $prompt
  )
  $val = $_stepPromptValues[$prompt]
  $dots = '.' * ($_stepPromptValuesMaxLen - $val.Length)
  $suff = " .$dots.. "
  Write-Host -NoNewline $val -ForegroundColor White
  Write-Host -NoNewline $suff -ForegroundColor Blue
}

function prompt_quit {
  param (
    [string] $Prompt = "Proceed?"
  )
  $res = Read-Host "$Prompt [yN]"
  if ($res -notin "Y", "y" ) { exit 1 }
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

function status_created { Write-Host "created" -ForegroundColor Yellow }
function status_linked { Write-Host "linked from context" -ForegroundColor DarkGreen }

#endregion

if ( -not (Test-Path $context_mount)) {
  Write-Host "This container requires a context mount for proper operation"
  Write-Host "Please mount a volume to: $context_mount"
  exit 1
  # prompt_quit "Proceed Anyway?"
}

# set up git-config with some defaults
if ( -not (Test-Path ~/.gitconfig)) {
  [Step]::Git | step_prompt
  if ( Test-Path $context_mount/gitconfig ) {
    status_linked
    ln -s $context_mount/gitconfig ~/.gitconfig
  }
  else {
    Write-Host "creating" -ForegroundColor Yellow
    touch $context_mount/gitconfig
    ln -s $context_mount/gitconfig ~/.gitconfig
    $uname = prompt_or_default "   name" $env:DEFAULT_GIT_USER
    $email = prompt_or_default "  email" $env:DEFAULT_GIT_EMAIL
    git config --global user.name $uname
    git config --global user.email $email
  }
}

# create linked ssh context for persistance
if ( -not (Test-Path ~/.ssh)) {
  [Step]::SSH | step_prompt
  if (-not (Test-Path $context_mount/ssh)) {
    New-Item $context_mount/ssh -ItemType Directory
    status_created
  }
  else { status_linked }
  ln -s $context_mount/ssh ~/.ssh
}

# create minimal ssh config if missing
if ( -not (Test-Path ~/.ssh/config )) {
  [Step]::SSHConfig | step_prompt
  @"
Host bitbucket.org
IdentityFile ~/.ssh/$ssh_key_bitbucket
"@ | Out-File ~/.ssh/config
  status_created

  # create related key for default config if missing
  if ( -not (Test-Path ~/.ssh/$ssh_key_bitbucket )) {
    [Step]::SSHConfigGitKey | step_prompt
    ssh-keygen -q -N '""' -f ~/.ssh/$ssh_key_bitbucket
    status_created
    Write-Host "   name: " -NoNewline
    Write-Host "$ssh_key_bitbucket" -ForegroundColor DarkGray
  }

  Write-Host "  Remember to register this public key with bitbucket:"
  Get-Content "~/.ssh/$ssh_key_bitbucket.pub" | Write-Host -ForegroundColor DarkGray
}

if ( -not (Test-Path ~/.ssh/$ssh_key_term)) {
  
}
