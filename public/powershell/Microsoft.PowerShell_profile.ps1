# ============================================================
# PowerShell Profile
# ============================================================


# ------------------------------------------------------------
# PSReadLine - Keyboard behavior
# ------------------------------------------------------------

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -EditMode Emacs


# ------------------------------------------------------------
# Prompt - Linux-style appearance
# ------------------------------------------------------------

$script:HomePath = $HOME
$script:Green = "$([char]27)[32m"
$script:Reset = "$([char]27)[0m"

function prompt {
    $path = $PWD.Path

    if ($path.StartsWith($script:HomePath, [StringComparison]::OrdinalIgnoreCase)) {
        $path = '~' + $path.Substring($script:HomePath.Length)
    }

    [Console]::Write("$script:Green$path$script:Reset> ")
}