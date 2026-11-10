# Support for computing the Git status in the background.
#
# Computing the status of a repository can be slow (e.g. for very large
# repositories or for repositories that contain large files that have to be
# checked by a clean filter like the one of Git LFS). Since the status is
# needed to render the prompt, a slow status makes the prompt slow.
#
# When $GitPromptSettings.EnableBackgroundStatus is enabled, the status is
# computed by a background process. The prompt uses the status as soon as it
# is available and keeps using the last known status while the next status is
# being computed. This way the prompt is rendered immediately, even for
# repositories where computing the status takes seconds.

# The state of the background status computation. It is $null when no status
# is being computed.
$script:BgStatus = $null

<#
.SYNOPSIS
    Starts the computation of the Git status in the background.
.DESCRIPTION
    Starts a 'git status' process that computes the status of the repository
    in the current directory. The output of the process is read asynchronously
    so that the process never blocks on a full pipe buffer.
#>
function script:Start-BackgroundGitStatus {
    param(
        [Parameter()]
        [string]
        $Directory,

        [Parameter()]
        [string[]]
        $Arguments
    )

    # Do not start a second status computation while one is still running.
    if ($script:BgStatus -and !$script:BgStatus.Completed) {
        return
    }

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = 'git'
    $startInfo.Arguments = ($Arguments -join ' ')
    $startInfo.WorkingDirectory = $Directory
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo

    try {
        $null = $process.Start()
    }
    catch {
        Write-Verbose "Unable to start the background Git status process: $_"
        $process.Dispose()
        return
    }

    $script:BgStatus = [PSCustomObject]@{
        Process   = $process
        # Read the output asynchronously. Otherwise the process would block
        # once the pipe buffer is full and would never finish.
        OutputTask = $process.StandardOutput.ReadToEndAsync()
        ErrorTask  = $process.StandardError.ReadToEndAsync()
        Output     = $null
        Completed  = $false
        Directory  = $Directory
    }
}

<#
.SYNOPSIS
    Waits for the background status computation to complete.
.DESCRIPTION
    Waits at most TimeoutMilliseconds for the background status computation to
    complete and returns the output of the 'git status' process. $null is
    returned when the computation did not complete in time.
#>
function script:Wait-BackgroundGitStatus {
    param(
        [Parameter()]
        [int]
        $TimeoutMilliseconds = 50
    )

    $state = $script:BgStatus
    if (!$state) { return $null }

    if (!$state.Completed) {
        if (!$state.Process.WaitForExit($TimeoutMilliseconds)) {
            return $null
        }

        # The process has exited, so the output tasks are about to complete.
        $null = $state.OutputTask.Wait(1000)
        $null = $state.ErrorTask.Wait(1000)

        $state.Output = $state.OutputTask.Result
        $state.Completed = $true
        $state.Process.Dispose()
    }

    $state.Output
}

<#
.SYNOPSIS
    Stops the background status computation.
#>
function script:Stop-BackgroundGitStatus {
    $state = $script:BgStatus
    if (!$state) { return }

    $script:BgStatus = $null

    try {
        if (!$state.Completed) {
            $state.Process.Kill()
        }
    }
    catch {
        Write-Verbose "Unable to stop the background Git status process: $_"
    }
    finally {
        $state.Process.Dispose()
    }
}
