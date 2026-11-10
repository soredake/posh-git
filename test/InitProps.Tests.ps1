BeforeAll {
    . $PSScriptRoot\Shared.ps1
}

Describe 'Module Initialization Properties Tests' {
    AfterEach {
        # Restore the module with the default initialization.
        Remove-Variable -Name PoshGit_InitProps -Scope Global -ErrorAction SilentlyContinue
        Import-Module $moduleManifestPath -ArgumentList $true, $false -Force
    }

    It 'Installs the prompt by default' {
        $poshGitPrompt = (& (Get-Module posh-git) { $script:GitPromptScriptBlock }).ToString()

        (Get-Command prompt).Definition | Should -Be $poshGitPrompt
    }

    It 'Does not install the prompt when the prompt is disabled' {
        $global:PoshGit_InitProps = @{
            DisablePoshGitPrompt = $true
        }

        Import-Module $moduleManifestPath -ArgumentList $true, $false -Force

        $poshGitPrompt = (& (Get-Module posh-git) { $script:GitPromptScriptBlock }).ToString()
        $currentPrompt = (Get-Command prompt -ErrorAction SilentlyContinue).Definition
        $currentPrompt | Should -Not -Be $poshGitPrompt
    }

    It 'Uses the provided version of Git' {
        $global:PoshGit_InitProps = @{
            LocalGitVersion = [System.Version]'2.39.2'
        }

        Import-Module $moduleManifestPath -ArgumentList $true, $false -Force

        $version = & (Get-Module posh-git) { $script:GitVersion }
        $version | Should -Be ([System.Version]'2.39.2')
    }

    It 'Uses the provided extensions of Git' {
        $global:PoshGit_InitProps = @{
            LocalGitExtensions = @{ flow = $true }
        }

        Import-Module $moduleManifestPath -ArgumentList $true, $false -Force

        $module = Get-Module posh-git
        $result = & $module GitTabExpansionInternal 'git flo'
        $result | Should -BeExactly 'flow'
    }
}
