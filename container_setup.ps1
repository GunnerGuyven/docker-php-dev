param( [switch] $Startup ) 

# Set-PSDebug -Trace 1

#region settings
$context_mount = "/mnt/context"
$ctx_gitconfig = "$context_mount/gitconfig"
$ctx_ssh = "$context_mount/ssh"
$ctx_config = "$context_mount/config"
$ctx_vscode = "$context_mount/vscode"
$ctx_bashrc = "$context_mount/bashrc"
$ctx_starship_cfg = "$ctx_config/starship.toml"
$ctx_pwsh_profile = "$ctx_config/powershell/Microsoft.PowerShell_profile.ps1"
$pub_ssh_term_keys = "/mnt/term_keys"
$php_ini_defaults_path = "/usr/src/php"         # php 5.4
$php_ini_defaults_path2 = "/usr/local/etc/php"  # php 7.4
$pub_php_ini_defaults = "/mnt/php_ini"
$ssh_key_bitbucket = $env:SSH_KEY_BITBUCKET ?? "id_docker_php_bitbucket"
$ssh_key_term = $env:SSH_KEY_TERM ?? "id_docker_php_ssh_term"
$ssh_key_term_regenerate = $env:SSH_KEY_TERM_REGENERATE
#endregion

#region prompt function helpers

enum Step {
  Git
  SSH
  SSHConfig
  SSHConfigGitKey
  PubTermKey
  SSHAuth
  VSCode
  ProfileConfig
  RootSSHStrategy
  AddDevUser
  AddBashRC
  AddPWSHProfile
  AddStarshipCfg
  DumpPHPINI
}
$_stepPromptValues = @(
  "Setting up Git defaults"
  "Adding SSH context"
  "Missing SSH config"
  "Generating Git Key"
  "Publishing Terminal Key"
  "  Creating Client Auth"
  "Adding VSCode context"
  "Adding Profile Config"
  "Root SSH access via"
  "Adding user 'dev'"
  "Shell Config Bash"
  "Shell Config Powershell"
  "Shell Config Starship"
  "Retrieving PHP defaults"
)
$_stepPromptValuesMaxLen = ($_stepPromptValues | Measure-Object -Maximum -Property Length).Maximum
function announce_step {
  param (
    [Parameter(ValueFromPipeline = $true)][Step] $Step
  )
  $val = $_stepPromptValues[$Step]
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
function status_linked { Write-Host "linked from context" -ForegroundColor DarkGreen }
function status_copied { Write-Host "copied from context" -ForegroundColor DarkGreen }

function create_or_context_dir {
  param(
    [string] $Target_Path,
    [string] $Context_Path,
    [Parameter(ValueFromPipeline = $true)][Step] $Step_to_announce
  )
  if ( -not (Test-Path $Target_Path)) {
    announce_step $step_to_announce
    if ( -not (Test-Path $Context_Path)) {
      New-Item $Context_Path -ItemType Directory | Out-Null
      status_created
    }
    else { status_linked }
    ln -s $Context_Path $Target_Path
  }
}

#endregion

if ( -not (Test-Path $context_mount)) {
  Write-Host "This container requires a context mount for proper operation"
  Write-Host "Please mount a volume to: " -NoNewline
  Write-Host $context_mount -ForegroundColor DarkMagenta
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

[Step]::SSH | create_or_context_dir ~/.ssh $ctx_ssh
[Step]::VSCode | create_or_context_dir ~/.vscode-server $ctx_vscode
[Step]::ProfileConfig | create_or_context_dir ~/.config $ctx_config

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

# produce ssh keys for making terminal connection to container
if ((Test-Path $pub_ssh_term_keys)) {
  [Step]::PubTermKey | announce_step
  if ( -not (Test-Path ~/.ssh/$ssh_key_term) -or $ssh_key_term_regenerate) {
    if ($ssh_key_term_regenerate) {
      Remove-Item @(
        "~/.ssh/authorized_keys"
        "~/.ssh/$ssh_key_term"
        "~/.ssh/$ssh_key_term.pub"
      )
    }
    ssh-keygen -q -N '""' -f ~/.ssh/$ssh_key_term
    if ($ssh_key_term_regenerate) { status_created }
    else { status_created }
    [Step]::SSHAuth | announce_step
    Get-Content "~/.ssh/$ssh_key_term.pub" | Out-File "~/.ssh/authorized_keys"
    status_created
  }
  else {
    status_copied
    Write-Host "  Info: " -NoNewline -ForegroundColor Blue
    Write-Host         "Terminal key already existed in context."
    Write-Host "        If you wish to generate it anew set the"
    Write-Host "        container environment variable: " -NoNewline
    Write-Host "SSH_KEY_TERM_REGENERATE" -ForegroundColor DarkMagenta
  }
  Copy-Item ~/.ssh/$ssh_key_term, ~/.ssh/$ssh_key_term.pub $pub_ssh_term_keys
  Write-Host "  Info: " -NoNewline -ForegroundColor Blue
  Write-Host         "key: " -NoNewline
  Write-Host $ssh_key_term -ForegroundColor DarkMagenta
  Write-Host "        placed in: " -NoNewline
  Write-Host $pub_ssh_term_keys -ForegroundColor DarkMagenta
  Write-Host "        This is the private half of the key you should"
  Write-Host "        use on your end in order to make an ssh"
  Write-Host "        connection to this running container."
}
# else {
#   Write-Host "  Info: " -NoNewline -ForegroundColor Blue
#   Write-Host         "Terminal key is available."
#   Write-Host "        To obtain it mount an external"
#   Write-Host "        volume to: " -NoNewline
#   Write-Host $pub_ssh_term_keys -ForegroundColor DarkMagenta
# }

if ($env:USER_DEV_PWORD) {
  [Step]::AddDevUser | announce_step
  groupadd -r dev && useradd -r -g dev dev
  mkdir /home/dev
  chown -R dev:dev /home/dev
  $u = $env:USER_DEV_PWORD
  Invoke-Expression "bash -c 'echo -e `"$u\\n$u`" | passwd dev &> null'"
  status_created
}

[Step]::RootSSHStrategy | announce_step
if ($env:USER_ROOT_PWORD) {
  $u = $env:USER_ROOT_PWORD
  sed -i 's|PermitRootLogin without-password|PermitRootLogin yes|' /etc/ssh/sshd_config
  Invoke-Expression "bash -c 'echo -e `"$u\\n$u`" | passwd &> /dev/null'"
  Write-Host "password" -ForegroundColor Red
}
else {
  sed -i 's|#PasswordAuthentication yes|PasswordAuthentication no|' /etc/ssh/sshd_config
  sed -i 's|UsePAM yes|UsePAM no|' /etc/ssh/sshd_config
  Write-Host "key only" -ForegroundColor Green 
}

#region Shell Defaults
if ( -not (Test-Path $ctx_pwsh_profile)) {
  [Step]::AddPWSHProfile | announce_step
  New-Item /mnt/context/config/powershell -ItemType Directory | Out-Null
  @'
function l { Invoke-Expression "ls --color=auto -lA $args" }
Invoke-Expression (&starship init powershell)
'@ | Out-File $ctx_pwsh_profile
  status_created
}
if ( -not (Test-Path $ctx_starship_cfg)) {
  [Step]::AddStarshipCfg | announce_step
  @'
[shell]
disabled = false
bash_indicator = ""
powershell_indicator = ""
style = "cyan bold"
'@ | Out-File $ctx_starship_cfg
  status_created
}
if (-not (Test-Path $ctx_bashrc)) {
  [Step]::AddBashRC | announce_step
  @'
# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

eval "$(starship init bash)"
'@ -split "`r`n" -join "`n" | Out-File $ctx_bashrc
  status_created
}
if (Test-Path ~/.bashrc) { Remove-Item -Force ~/.bashrc }
ln -s $ctx_bashrc ~/.bashrc
#endregion

if (Test-Path $pub_php_ini_defaults) {
  [Step]::DumpPHPINI | announce_step
  if (Test-Path $php_ini_defaults_path) {
    Copy-Item $php_ini_defaults_path/php.ini-* $pub_php_ini_defaults/
  }
  else {
    Copy-Item $php_ini_defaults_path2/php.ini-* $pub_php_ini_defaults/
  }
  status_copied
}

if ($Startup) {
  Invoke-Expression "service ssh start"
  php-fpm
}

