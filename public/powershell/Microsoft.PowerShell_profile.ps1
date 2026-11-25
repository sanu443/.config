# ============================================================
# PowerShell Profile
# ============================================================


# ------------------------------------------------------------
# PSReadLine - Keyboard behavior
# ------------------------------------------------------------

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -EditMode Emacs

Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow  -Function BackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord

# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------
Set-Alias -Name c -Value code

# ------------------------------------------------------------
# Prompt - Linux-style appearance
# ------------------------------------------------------------

$script:HomePath = $HOME
$script:Green = "$([char]27)[1;32m"
$script:Reset = "$([char]27)[0m"

function prompt {
    $path = $PWD.Path

    if ($path.StartsWith($script:HomePath, [StringComparison]::OrdinalIgnoreCase)) {
        $path = '~' + $path.Substring($script:HomePath.Length)
    }

    [Console]::Write("$script:Green$path$script:Reset> ")
}

# ------------------------------------------------------------
# Zoxide
# ------------------------------------------------------------

Invoke-Expression (& { (zoxide init powershell | Out-String) }) 
. "$HOME\Desktop\home-repo\wiki\.config\public\powershell\_zoxide.ps1"