function l { Invoke-Expression "ls --color=auto -lA $args" }
Invoke-Expression (&starship init powershell)
