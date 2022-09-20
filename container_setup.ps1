

# Set-PSDebug -Trace 1

#region settings
$context_mount = "/mnt/context"
$ctx_gitconfig = "$context_mount/gitconfig"
$ctx_ssh = "$context_mount/ssh"
$ctx_ssh_term_keys = "$context_mount/term"
$pub_ssh_term_keys = "/mnt/term_keys"
$ssh_term_keys_regenerate = Test-Path $pub_ssh_term_keys/regen
$ssh_key_bitbucket = $env:SSH_KEY_BITBUCKET ?? "id_docker_php_bitbucket"
$ssh_key_term = $env:SSH_KEY_TERM ?? "id_docker_php_ssh_term"
#endregion

#region prompt function helpers

enum Step {
  Git
  SSH
  SSHConfig
  SSHConfigGitKey
  SSHTermKey
  PubTermKey
}
$_stepPromptValues = @(
  "Setting up Git defaults"
  "Adding SSH context"
  "Missing SSH config"
  "Generating Git Key"
  "Generating Terminal Key"
  "Publishing Terminal Key"
)
$_stepPromptValuesMaxLen = ($_stepPromptValues | Measure-Object -Maximum -Property Length).Maximum
function announce_step {
  param (
    [Parameter(ValueFromPipeline = $true)][Step] $prompt
  )
  $val = $_stepPromptValues[$prompt]
  $dots = '.' * ($_stepPromptValuesMaxLen - $val.Length + 3)
  Write-Host -NoNewline $val -ForegroundColor White
  Write-Host -NoNewline " $dots " -ForegroundColor Blue
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
function status_creating { Write-Host "creating" -ForegroundColor Yellow }
function status_recreated { Write-Host "recreated" -ForegroundColor Blue }
function status_linked { Write-Host "linked from context" -ForegroundColor DarkGreen }

#endregion

if ( -not (Test-Path $context_mount)) {
  Write-Host "This container requires a context mount for proper operation"
  Write-Host "Please mount a volume to: " -NoNewline
  Write-Host $context_mount -ForegroundColor Cyan
  exit 1
  # prompt_quit "Proceed Anyway?"
}

# set up git-config with some defaults
if ( -not (Test-Path ~/.gitconfig)) {
  [Step]::Git | announce_step
  if ( Test-Path $ctx_gitconfig ) {
    status_linked
    ln -s $ctx_gitconfig ~/.gitconfig
  }
  else {
    status_creating
    touch $ctx_gitconfig
    ln -s $ctx_gitconfig ~/.gitconfig
    $uname = prompt_or_default "   name" $env:DEFAULT_GIT_USER
    $email = prompt_or_default "  email" $env:DEFAULT_GIT_EMAIL
    git config --global user.name $uname
    git config --global user.email $email
  }
}

# create linked ssh context for persistance
if ( -not (Test-Path ~/.ssh)) {
  [Step]::SSH | announce_step
  if (-not (Test-Path $ctx_ssh)) {
    New-Item $ctx_ssh -ItemType Directory
    status_created
  }
  else { status_linked }
  ln -s $ctx_ssh ~/.ssh
}

# create minimal ssh config if missing
if ( -not (Test-Path ~/.ssh/config )) {
  [Step]::SSHConfig | announce_step
  @"
Host bitbucket.org
IdentityFile ~/.ssh/$ssh_key_bitbucket
"@ | Out-File ~/.ssh/config
  status_created

  # create related key for default config if missing
  if ( -not (Test-Path ~/.ssh/$ssh_key_bitbucket )) {
    [Step]::SSHConfigGitKey | announce_step
    ssh-keygen -q -N '""' -f ~/.ssh/$ssh_key_bitbucket
    status_created
    Write-Host "   name: " -NoNewline
    Write-Host "$ssh_key_bitbucket" -ForegroundColor DarkGray
  }

  Write-Host "  Remember to register this public key with bitbucket:"
  Get-Content "~/.ssh/$ssh_key_bitbucket.pub" | Write-Host -ForegroundColor DarkGray
}

if ( -not (Test-Path ~/.ssh/$ssh_key_term) -or $ssh_term_keys_regenerate) {
  [Step]::SSHTermKey | announce_step
  if ($ssh_term_keys_regenerate) {
    Remove-Item @(
      "~/.ssh/authorized_keys"
      "~/.ssh/$ssh_key_term"
      "~/.ssh/$ssh_key_term.pub"
    )
  }
  ssh-keygen -q -N '""' -f ~/.ssh/$ssh_key_term
  if ($ssh_term_keys_regenerate) { status_recreated }
  else { status_created }
  $ssh_term_keys_regenerate = $true #signal that we did work here
}

if ((Test-Path $pub_ssh_term_keys) -or $true) {
  [Step]::PubTermKey | announce_step
  if (-not $ssh_term_keys_regenerate) {
    status_linked
    Write-Host "  Note: " -NoNewline -ForegroundColor Red
    Write-Host         "Previous terminal keys exist," # -ForegroundColor DarkGray
    Write-Host "        to regenerate them place a file" # -ForegroundColor DarkGray
    Write-Host "        named 'regen' in the root of the" # -ForegroundColor DarkGray
    Write-Host "        mount: " -NoNewline # -ForegroundColor DarkGray
    Write-Host $pub_ssh_term_keys -ForegroundColor Cyan
  }
  
}
