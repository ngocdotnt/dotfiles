# Reduced the loading time - FrankkC (Stackoverflow)
$PSModuleAutoLoadingPreference = 'None'
Import-Module Microsoft.PowerShell.Utility
Import-Module Microsoft.PowerShell.Management
# Set PowerShel to UTF-8
# [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# OhMyPosh
#oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/json.omp.json" | Invoke-Expression

Import-Module -Name Terminal-Icons

# Starship
Invoke-Expression (&starship init powershell)

# colors
$colors = @{
    "Operator"         = "`e[35m" # Purple
    "Parameter"        = "`e[36m" # Cyan
    "String"           = "`e[32m" # Green
    "Command"          = "`e[34m" # Blue
    "Variable"         = "`e[37m" # White
    "Comment"          = "`e[38;5;244m" # Gray
    "InlinePrediction" = "`e[38;5;244m" # Gray
}

# PSReadLine
Set-PSReadLineOption -Colors $colors
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView

# Fzf
Import-Module PSFzf
Set-PSFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Env
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"
$env:BAT_CONFIG_DIR = "$HOME\.config\bat"
$env:XDG_CONFIG_HOME="C:\Users\Admin\.config"
$env:TERM='xterm-256color'
$env:ZK_NOTEBOOK_DIR="$HOME\my-notes"

# Alias =============================================================================
Set-Alias ll ls
Set-Alias grep findstr

# Functions =========================================================================

function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
      Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function Toggle-Taskbar {
    <#
    .SYNOPSIS
      New command Show/Hide Windows's Taskbar
    #>
    $file = "$env:TEMP\TaskBarState.txt"
    if (Test-Path -Path $file) {
        & "nircmd.exe" win trans class Shell_TrayWnd 256
        Remove-Item -Path $file
    } else {
        & "nircmd.exe" win trans class Shell_TrayWnd 255
        New-Item -Path $file -ItemType File | Out-Null
    }
}

function New-File {
    <#
    .SYNOPSIS
      Creates a new file with the specified name and extension. Alias: touch
    #>
    [CmdletBinding()]
    param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name
    )

    Write-Verbose "Creating new file '$Name"
    New-Item -ItemType File -Name $Name -Path $PWD | Out-Null
}
Set-Alias touch -Value New-File

function Get-Memory {
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, @{Name='Memor (MB}'; Expression={[math]::round($_.WorkingSet / 1MB, 2)}}
}
Set-Alias memoryUsed -Value Get-Memory

# =============================================================================
#
# Utility functions for zoxide.
#

# Call zoxide binary, returning the output as UTF-8.
function global:__zoxide_bin {
    $encoding = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = [System.Text.Utf8Encoding]::new()
        $result = zoxide @args
        return $result
    } finally {
        [Console]::OutputEncoding = $encoding
    }
}

# pwd based on zoxide's format.
function global:__zoxide_pwd {
    $cwd = Get-Location
    if ($cwd.Provider.Name -eq "FileSystem") {
        $cwd.ProviderPath
    }
}

# cd + custom logic based on the value of _ZO_ECHO.
function global:__zoxide_cd($dir, $literal) {
    $dir = if ($literal) {
        Set-Location -LiteralPath $dir -Passthru -ErrorAction Stop
    } else {
        if ($dir -eq '-' -and ($PSVersionTable.PSVersion -lt 6.1)) {
            Write-Error "cd - is not supported below PowerShell 6.1. Please upgrade your version of PowerShell."
        }
        elseif ($dir -eq '+' -and ($PSVersionTable.PSVersion -lt 6.2)) {
            Write-Error "cd + is not supported below PowerShell 6.2. Please upgrade your version of PowerShell."
        }
        else {
            Set-Location -Path $dir -Passthru -ErrorAction Stop
        }
    }
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
$global:__zoxide_oldpwd = __zoxide_pwd
function global:__zoxide_hook {
    $result = __zoxide_pwd
    if ($result -ne $global:__zoxide_oldpwd) {
        if ($null -ne $result) {
            zoxide add -- $result
        }
        $global:__zoxide_oldpwd = $result
    }
}

# Initialize hook.
$global:__zoxide_hooked = (Get-Variable __zoxide_hooked -ErrorAction SilentlyContinue -ValueOnly)
if ($global:__zoxide_hooked -ne 1) {
    $global:__zoxide_hooked = 1
    $global:__zoxide_prompt_old = $function:prompt

    function global:prompt {
        if ($null -ne $__zoxide_prompt_old) {
            & $__zoxide_prompt_old
        }
        $null = __zoxide_hook
    }
}

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function global:__zoxide_z {
    if ($args.Length -eq 0) {
        __zoxide_cd ~ $true
    }
    elseif ($args.Length -eq 1 -and ($args[0] -eq '-' -or $args[0] -eq '+')) {
        __zoxide_cd $args[0] $false
    }
    elseif ($args.Length -eq 1 -and (Test-Path $args[0] -PathType Container)) {
        __zoxide_cd $args[0] $true
    }
    else {
        $result = __zoxide_pwd
        if ($null -ne $result) {
            $result = __zoxide_bin query --exclude $result -- @args
        }
        else {
            $result = __zoxide_bin query -- @args
        }
        if ($LASTEXITCODE -eq 0) {
            __zoxide_cd $result $true
        }
    }
}

# Jump to a directory using interactive search.
function global:__zoxide_zi {
    $result = __zoxide_bin query -i -- @args
    if ($LASTEXITCODE -eq 0) {
        __zoxide_cd $result $true
    }
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force

# =============================================================================
#
# To initialize zoxide, add this to your configuration (find it by running
# `echo $profile` in PowerShell):
#
Invoke-Expression (& { (zoxide init powershell | Out-String) })
#
#

function Stop-Zebar {
    Get-Process | Where-Object { $_.ProcessName -eq "zebar" } | Foreach-Object { Stop-Process -id $_.id -Force }
  }

# =============================================================================
#
# Wezterm OSC 7
#
$prompt = ""
function Invoke-Starship-PreCommand {
    $current_location = $executionContext.SessionState.Path.CurrentLocation
    if ($current_location.Provider.Name -eq "FileSystem") {
        $ansi_escape = [char]27
        $provider_path = $current_location.ProviderPath -replace "\\", "/"
        $prompt = "$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}$ansi_escape\"
    }
    $host.ui.Write($prompt)
}

#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58

# Neovim config home

# For Scoop search
Invoke-Expression (&sfsu hook)


# Function to select Neovim configuration interactively
function nvims {
    param(
        [string]$FilePath
    )
    $items = @("default", "nvim-lazy", "nvim-deps", "nvim-lazyvim", "nvim-pkazmier", "nvim-vineeth")
    $config = $items | fzf --prompt=" Neovim Config " --height=50% --layout=reverse --border
    if (-not $config) {
        Write-Output "Nothing selected"
        return
    } elseif ($config -eq "default") {
        $env:NVIM_APPNAME = ""
    } else {
        $env:NVIM_APPNAME = $config
    }
    $arg = $FilePath
    if (-not $arg) {
        nvim
    } else {
        nvim $arg
    }
}

# Alias for neovim
Set-Alias -Name vi -Value nvims

# Admin Session
function Start-AdminSession {
    <#
    .SYNOPSIS
        Starts a new PowerShell session with elevated rights. Alias: su
    #>
    Start-Process wt -Verb runAs
}
Set-Alias -Name su -Value Start-AdminSession

# Skip fastfetch for no-interaction shells
# if ([Environment]::GetcommandLineArgs().Contains("-NonInteractive")) {
#     return
# }
# fastfetch --logo $HOME\.config\fastfetch\logos\ascii.txt
