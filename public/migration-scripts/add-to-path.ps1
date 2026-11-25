[CmdletBinding(SupportsShouldProcess = $true)]
param()

$ErrorActionPreference = 'Stop'

$candidatePaths = [System.Collections.Generic.List[string]]::new()
$publicBin = Join-Path (Split-Path -Parent $PSScriptRoot) 'bin'
if (Test-Path -LiteralPath $publicBin -PathType Container) {
    $candidatePaths.Add($publicBin)
}
else {
    Write-Warning "The expected public bin directory was not found: $publicBin"
}

$programsDirectory = Join-Path $env:LOCALAPPDATA 'Programs'
$pythonDirectory = Join-Path $programsDirectory 'Python'
if (Test-Path -LiteralPath $pythonDirectory -PathType Container) {
    foreach ($installation in Get-ChildItem -LiteralPath $pythonDirectory -Directory -Filter 'Python*') {
        $candidatePaths.Add($installation.FullName)
        $scriptsDirectory = Join-Path $installation.FullName 'Scripts'
        if (Test-Path -LiteralPath $scriptsDirectory -PathType Container) {
            $candidatePaths.Add($scriptsDirectory)
        }
    }
}

if (Test-Path -LiteralPath $programsDirectory -PathType Container) {
    foreach ($installation in Get-ChildItem -LiteralPath $programsDirectory -Directory -Filter 'nodejs*') {
        $candidatePaths.Add($installation.FullName)
    }
}

$glabBin = Join-Path $env:LOCALAPPDATA 'glab-cli\bin'
if (Test-Path -LiteralPath $glabBin -PathType Container) {
    $candidatePaths.Add($glabBin)
}

function Get-NormalizedPathEntry {
    param([string]$PathEntry)

    return $PathEntry.Trim().Trim('"').TrimEnd([char[]]@('\', '/'))
}

$machineEntries = @(
    [Environment]::GetEnvironmentVariable('Path', 'Machine') -split ';' |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
)
$userEntries = @(
    [Environment]::GetEnvironmentVariable('Path', 'User') -split ';' |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
)
$knownEntries = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)

foreach ($entry in @($machineEntries) + @($userEntries)) {
    [void]$knownEntries.Add((Get-NormalizedPathEntry $entry))
}

$entriesToAdd = [System.Collections.Generic.List[string]]::new()
foreach ($candidate in $candidatePaths) {
    if (-not (Test-Path -LiteralPath $candidate -PathType Container)) {
        continue
    }

    $normalizedCandidate = Get-NormalizedPathEntry $candidate
    if ($knownEntries.Add($normalizedCandidate)) {
        $entriesToAdd.Add($candidate)
    }
}

if ($entriesToAdd.Count -eq 0) {
    Write-Host 'No missing custom PATH entries were found.'
    return
}

$updatedUserPath = (@($userEntries) + @($entriesToAdd)) -join ';'
$entryNoun = if ($entriesToAdd.Count -eq 1) { 'entry' } else { 'entries' }
$action = "Add $($entriesToAdd.Count) custom PATH $entryNoun"
if ($PSCmdlet.ShouldProcess('Current user PATH', $action)) {
    [Environment]::SetEnvironmentVariable('Path', $updatedUserPath, 'User')
    Write-Host 'Added to the current user PATH:'
    foreach ($entry in $entriesToAdd) {
        Write-Host "  $entry"
    }
    Write-Host 'Open a new terminal for the updated PATH to take effect.'
}