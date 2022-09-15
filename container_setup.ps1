
$context_mount="/mnt/context"

function prompt_quit {
  param (
    [string] $Prompt = "Proceed?"
  )
  $res = Read-Host "$Prompt [yN]"
  if ($res -notin "Y", "y" ) { exit 1 }
}

if ( -not (Test-Path $context_mount -PathType Container)) {
  Write-Host "This container requires a context mount for proper operation"
  Write-Host "Please mount a volume to: $context_mount"
  prompt_quit "Proceed Anyway?"
}

# prompt_quit

Write-Output "didn't quit"