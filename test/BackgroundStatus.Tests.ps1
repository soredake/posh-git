BeforeAll {
    . $PSScriptRoot\Shared.ps1
}

Describe 'Background Status Tests' {
    BeforeAll {
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
        $repoPath = NewGitTempRepo -MakeInitialCommit

        'dirty' | Out-File ./dirty.txt
    }
    AfterAll {
        RemoveGitTempRepo $repoPath
    }
    AfterEach {
        $GitPromptSettings.EnableBackgroundStatus = $false
    }

    It 'Computes the status in a background process' {
        $text = & $module {
            Start-BackgroundGitStatus -Directory $PWD.Path -Arguments @('status', '--short', '--branch')
            Wait-BackgroundGitStatus -TimeoutMilliseconds 30000
        }

        $text | Should -Not -BeNullOrEmpty
        $text | Should -BeLike '*## *'
    }

    It 'Returns the status of the repository from the background process' {
        $status = & $module {
            Get-BackgroundGitStatus -TimeoutMilliseconds 30000
        }

        $status | Should -Not -BeNullOrEmpty
        $status.Branch | Should -Be 'master'
        $status.HasUntracked | Should -Be $true
        $status.Working.Added | Should -Contain 'dirty.txt'
    }

    It 'Keeps the last known status when the background status is not available in time' {
        $GitPromptSettings.EnableBackgroundStatus = $true
        $GitPromptSettings.BackgroundStatusTimeout = 0

        # The first call computes the status, because there is no status yet.
        $first = Write-VcsStatus
        $first | Should -Not -BeNullOrEmpty

        # The second call cannot get a new status in time, so the status of the
        # previous prompt is used.
        $second = Write-VcsStatus
        $second | Should -Not -BeNullOrEmpty
        $second | Should -Be $first
    }

    It 'Uses the status from Git when the background status is disabled' {
        $GitPromptSettings.EnableBackgroundStatus = $false

        $status = Write-VcsStatus
        $status | Should -Not -BeNullOrEmpty
    }
}
