$global:GitMissing = $false
$script:GitCygwin = $false
$script:GitVersion = $requiredVersion = [System.Version]'2.15'

# The version of Git can be provided when the module is imported, so that Git
# does not have to be asked for it. Asking Git for its version can be slow,
# e.g. when the machine is scanned by a virus scanner.
$providedGitVersion = $script:InitProps['LocalGitVersion']

if (!$providedGitVersion -and !(Get-Command git -TotalCount 1 -ErrorAction SilentlyContinue)) {
    Write-Warning "git command could not be found. Please create an alias or add it to your PATH."
    $global:GitMissing = $true
    return
}

function Test-GitVersion ($version = $([string](git --version 2> $null))) {
    if ($version -notmatch '(?<ver>\d+(?:\.\d+)+)(?<g4w>(?<rc>[-.]rc\d+)?\.windows|\.vfs)?') {
        Write-Warning "posh-git could not parse Git version ($version)"
        $script:GitVersion = $version
        return $false
    }

    # On Windows, check if Git is not "Git for Windows"
    if ((($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows) -and !$Matches['g4w']) {
        $script:GitCygwin = $true

        if (!$Env:POSHGIT_CYGWIN_WARNING) {
            Write-Warning 'You appear to have an unsupported Git distribution; setting $GitPromptSettings.AnsiConsole = $false. posh-git recommends Git for Windows.'
        }
    }

    $script:GitVersion = [System.Version]$Matches['ver']

    return $GitVersion -ge $requiredVersion
}

if ($providedGitVersion) {
    # The version of Git is known, so Git is not asked for it. Note that the
    # check for an unsupported Git distribution is not possible then.
    $script:GitVersion = [System.Version]$providedGitVersion

    if ($script:GitVersion -lt $requiredVersion) {
        Write-Warning "posh-git requires Git $requiredVersion or better. You have $script:GitVersion."
    }
}
elseif (!(Test-GitVersion)) {
    Write-Warning "posh-git requires Git $requiredVersion or better. You have $GitVersion."
}
