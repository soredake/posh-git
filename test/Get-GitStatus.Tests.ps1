# For info on Pester mocking see - http://www.powershellmagazine.com/2014/09/30/pester-mock-and-testdrive/
BeforeAll {
    . $PSScriptRoot\Shared.ps1
}

Describe 'Get-GitStatus Tests' {
    Context 'Get-GitStatus Working Directory Tests' {
        BeforeAll {
            Set-Location $PSScriptRoot
        }

        It 'Returns the correct branch name' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head rkeithill/more-status-tests
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.Branch | Should -Be "rkeithill/more-status-tests"
            $status.HasIndex | Should -Be $false
            $status.HasUntracked | Should -Be $false
            $status.HasWorking | Should -Be $false
            $status.Working.Added.Count | Should -Be 0
            $status.Working.Deleted.Count | Should -Be 0
            $status.Working.Modified.Count | Should -Be 0
            $status.Working.Unmerged.Count | Should -Be 0
            $status.Index.Added.Count | Should -Be 0
            $status.Index.Deleted.Count | Should -Be 0
            $status.Index.Modified.Count | Should -Be 0
            $status.Index.Unmerged.Count | Should -Be 0
        }


        It 'Returns the correct number of added untracked working files' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
? test/Foo.Tests.ps1
? test/Bar.Tests.ps1
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.HasIndex | Should -Be $false
            $status.HasUntracked | Should -Be $true
            $status.HasWorking | Should -Be $true
            $status.Working.Added.Count | Should -Be 2
            $status.Working.Deleted.Count | Should -Be 0
            $status.Working.Modified.Count | Should -Be 0
            $status.Working.Unmerged.Count | Should -Be 0
            $status.Working.Added[0] | Should -Be "test/Foo.Tests.ps1"
            $status.Working.Added[1] | Should -Be "test/Bar.Tests.ps1"
        }
        It 'Returns the correct number of added working files' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
1 .A N... 000000 000000 100644 0000000000000000000000000000000000000000 0000000000000000000000000000000000000000 test/Foo.Tests.ps1
1 .A N... 000000 000000 100644 0000000000000000000000000000000000000000 0000000000000000000000000000000000000000 test/Bar.Tests.ps1
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.HasIndex | Should -Be $false
            $status.HasUntracked | Should -Be $true
            $status.HasWorking | Should -Be $true
            $status.Working.Added.Count | Should -Be 2
            $status.Working.Deleted.Count | Should -Be 0
            $status.Working.Modified.Count | Should -Be 0
            $status.Working.Unmerged.Count | Should -Be 0
            $status.Working.Added[0] | Should -Be "test/Foo.Tests.ps1"
            $status.Working.Added[1] | Should -Be "test/Bar.Tests.ps1"
        }
        It 'Returns the correct number of deleted working files' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
1 .D N... 100644 100644 000000 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 test/Foo.Tests.ps1
1 .D N... 100644 100644 000000 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 test/Bar.Tests.ps1
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.HasIndex | Should -Be $false
            $status.HasUntracked | Should -Be $false
            $status.HasWorking | Should -Be $true
            $status.Working.Added.Count | Should -Be 0
            $status.Working.Deleted.Count | Should -Be 2
            $status.Working.Modified.Count | Should -Be 0
            $status.Working.Unmerged.Count | Should -Be 0
            $status.Working.Deleted[0] | Should -Be "test/Foo.Tests.ps1"
            $status.Working.Deleted[1] | Should -Be "test/Bar.Tests.ps1"
        }
        It 'Returns the correct number of modified working files' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
1 .M N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 test/Foo.Tests.ps1
1 .M N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 test/Bar.Tests.ps1
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.HasIndex | Should -Be $false
            $status.HasUntracked | Should -Be $false
            $status.HasWorking | Should -Be $true
            $status.Working.Added.Count | Should -Be 0
            $status.Working.Deleted.Count | Should -Be 0
            $status.Working.Modified.Count | Should -Be 2
            $status.Working.Unmerged.Count | Should -Be 0
            $status.Working.Modified[0] | Should -Be "test/Foo.Tests.ps1"
            $status.Working.Modified[1] | Should -Be "test/Bar.Tests.ps1"
        }
        It 'Returns the correct number of unmerged working files' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
u .U N... 100644 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 4444444444444444444444444444444444444444 test/Foo.Tests.ps1
u .U N... 100644 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 4444444444444444444444444444444444444444 test/Bar.Tests.ps1
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.HasIndex | Should -Be $false
            $status.HasUntracked | Should -Be $false
            $status.HasWorking | Should -Be $true
            $status.Working.Added.Count | Should -Be 0
            $status.Working.Deleted.Count | Should -Be 0
            $status.Working.Modified.Count | Should -Be 0
            $status.Working.Unmerged.Count | Should -Be 2
            $status.Working.Unmerged[0] | Should -Be "test/Foo.Tests.ps1"
            $status.Working.Unmerged[1] | Should -Be "test/Bar.Tests.ps1"
        }
        It 'Returns the correct number of mixed working files' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
? test/Untracked.Tests.ps1
1 .A N... 000000 000000 100644 0000000000000000000000000000000000000000 0000000000000000000000000000000000000000 test/Added.Tests.ps1
1 .D N... 100644 100644 000000 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 test/Deleted.Tests.ps1
1 .M N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 test/Modified.Tests.ps1
u .U N... 100644 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 4444444444444444444444444444444444444444 test/Unmerged.Tests.ps1
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.HasIndex | Should -Be $false
            $status.HasUntracked | Should -Be $true
            $status.HasWorking | Should -Be $true
            $status.Working.Added.Count | Should -Be 2
            $status.Working.Deleted.Count | Should -Be 1
            $status.Working.Modified.Count | Should -Be 1
            $status.Working.Unmerged.Count | Should -Be 1
            $status.Working.Added[0] | Should -Be "test/Untracked.Tests.ps1"
            $status.Working.Added[1] | Should -Be "test/Added.Tests.ps1"
            $status.Working.Deleted[0] | Should -Be "test/Deleted.Tests.ps1"
            $status.Working.Modified[0] | Should -Be "test/Modified.Tests.ps1"
            $status.Working.Unmerged[0] | Should -Be "test/Unmerged.Tests.ps1"
        }

        It 'Returns the correct number of added index files' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
1 A. N... 000000 100644 100644 0000000000000000000000000000000000000000 3333333333333333333333333333333333333333 test/Foo.Tests.ps1
1 A. N... 000000 100644 100644 0000000000000000000000000000000000000000 3333333333333333333333333333333333333333 test/Bar.Tests.ps1
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.HasIndex | Should -Be $true
            $status.HasUntracked | Should -Be $false
            $status.HasWorking | Should -Be $false
            $status.Index.Added.Count | Should -Be 2
            $status.Index.Deleted.Count | Should -Be 0
            $status.Index.Modified.Count | Should -Be 0
            $status.Index.Unmerged.Count | Should -Be 0
            $status.Index.Added[0] | Should -Be "test/Foo.Tests.ps1"
            $status.Index.Added[1] | Should -Be "test/Bar.Tests.ps1"
        }
        It 'Returns the correct number of deleted index files' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
1 D. N... 100644 000000 000000 2222222222222222222222222222222222222222 0000000000000000000000000000000000000000 test/Foo.Tests.ps1
1 D. N... 100644 000000 000000 2222222222222222222222222222222222222222 0000000000000000000000000000000000000000 test/Bar.Tests.ps1
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.HasIndex | Should -Be $true
            $status.HasUntracked | Should -Be $false
            $status.HasWorking | Should -Be $false
            $status.Index.Added.Count | Should -Be 0
            $status.Index.Deleted.Count | Should -Be 2
            $status.Index.Modified.Count | Should -Be 0
            $status.Index.Unmerged.Count | Should -Be 0
            $status.Index.Deleted[0] | Should -Be "test/Foo.Tests.ps1"
            $status.Index.Deleted[1] | Should -Be "test/Bar.Tests.ps1"
        }
        It 'Returns the correct number of copied index files' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
2 C. N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 C100 test/Foo.Tests.ps1	test/Foo.Tests.ps1
2 C. N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 C100 test/Bar.Tests.ps1	test/Bar.Tests.ps1
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.HasIndex | Should -Be $true
            $status.HasUntracked | Should -Be $false
            $status.HasWorking | Should -Be $false
            $status.Index.Added.Count | Should -Be 0
            $status.Index.Deleted.Count | Should -Be 0
            $status.Index.Modified.Count | Should -Be 2
            $status.Index.Unmerged.Count | Should -Be 0
            $status.Index.Modified[0] | Should -Be "test/Foo.Tests.ps1"
            $status.Index.Modified[1] | Should -Be "test/Bar.Tests.ps1"
        }
        It 'Returns the correct number of modified index files' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
1 M. N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 test/Foo.Tests.ps1
1 M. N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 test/Bar.Tests.ps1
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.HasIndex | Should -Be $true
            $status.HasUntracked | Should -Be $false
            $status.HasWorking | Should -Be $false
            $status.Index.Added.Count | Should -Be 0
            $status.Index.Deleted.Count | Should -Be 0
            $status.Index.Modified.Count | Should -Be 2
            $status.Index.Unmerged.Count | Should -Be 0
            $status.Index.Modified[0] | Should -Be "test/Foo.Tests.ps1"
            $status.Index.Modified[1] | Should -Be "test/Bar.Tests.ps1"
        }
        It 'Returns the correct number of modified index files for a rename' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
2 R. N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 R100 README2.md	README.md
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.HasIndex | Should -Be $true
            $status.HasUntracked | Should -Be $false
            $status.HasWorking | Should -Be $false
            $status.Index.Added.Count | Should -Be 0
            $status.Index.Deleted.Count | Should -Be 0
            $status.Index.Modified.Count | Should -Be 1
            $status.Index.Unmerged.Count | Should -Be 0
            $status.Index.Modified[0] | Should -Be "README.md"
        }
        It 'Returns the correct number of unmerged index files' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
u U. N... 100644 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 4444444444444444444444444444444444444444 test/Foo.Tests.ps1
u U. N... 100644 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 4444444444444444444444444444444444444444 test/Bar.Tests.ps1
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.HasIndex | Should -Be $true
            $status.HasUntracked | Should -Be $false
            $status.HasWorking | Should -Be $false
            $status.Index.Added.Count | Should -Be 0
            $status.Index.Deleted.Count | Should -Be 0
            $status.Index.Modified.Count | Should -Be 0
            $status.Index.Unmerged.Count | Should -Be 2
            $status.Index.Unmerged[0] | Should -Be "test/Foo.Tests.ps1"
            $status.Index.Unmerged[1] | Should -Be "test/Bar.Tests.ps1"
        }
        It 'Returns the correct number of mixed index files' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
1 A. N... 000000 100644 100644 0000000000000000000000000000000000000000 3333333333333333333333333333333333333333 test/Added.Tests.ps1
1 D. N... 100644 000000 000000 2222222222222222222222222222222222222222 0000000000000000000000000000000000000000 test/Deleted.Tests.ps1
2 C. N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 C100 test/Copied.Tests.ps1	test/Copied.Tests.ps1
2 R. N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 R100 README2.md	README.md
1 M. N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 test/Modified.Tests.ps1
u U. N... 100644 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 4444444444444444444444444444444444444444 test/Unmerged.Tests.ps1
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.HasIndex | Should -Be $true
            $status.HasUntracked | Should -Be $false
            $status.HasWorking | Should -Be $false
            $status.Index.Added.Count | Should -Be 1
            $status.Index.Deleted.Count | Should -Be 1
            $status.Index.Modified.Count | Should -Be 3
            $status.Index.Unmerged.Count | Should -Be 1
            $status.Index.Added[0] | Should -Be "test/Added.Tests.ps1"
            $status.Index.Deleted[0] | Should -Be "test/Deleted.Tests.ps1"
            $status.Index.Modified[0] | Should -Be "test/Copied.Tests.ps1"
            $status.Index.Modified[1] | Should -Be "README.md"
            $status.Index.Modified[2] | Should -Be "test/Modified.Tests.ps1"
            $status.Index.Unmerged[0] | Should -Be "test/Unmerged.Tests.ps1"
        }

        It 'Returns the correct number of mixed index and working files' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
1 A. N... 000000 100644 100644 0000000000000000000000000000000000000000 3333333333333333333333333333333333333333 test/Added.Tests.ps1
1 D. N... 100644 000000 000000 2222222222222222222222222222222222222222 0000000000000000000000000000000000000000 test/Deleted.Tests.ps1
2 C. N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 C100 test/Copied.Tests.ps1	test/Copied.Tests.ps1
2 R. N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 R100 README2.md	README.md
1 M. N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 test/Modified.Tests.ps1
u U. N... 100644 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 4444444444444444444444444444444444444444 test/Unmerged.Tests.ps1
? test/Untracked.Tests.ps1
1 .A N... 000000 000000 100644 0000000000000000000000000000000000000000 0000000000000000000000000000000000000000 test/Added.Tests.ps1
1 .D N... 100644 100644 000000 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 test/Deleted.Tests.ps1
1 .M N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 test/Modified.Tests.ps1
u .U N... 100644 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 4444444444444444444444444444444444444444 test/Unmerged.Tests.ps1
'@
            }

            $status = Get-GitStatus
            Should -Invoke -ModuleName posh-git -CommandName git -Exactly 1
            $status.HasIndex | Should -Be $true
            $status.HasUntracked | Should -Be $true
            $status.HasWorking | Should -Be $true
            $status.Working.Added.Count | Should -Be 2
            $status.Working.Deleted.Count | Should -Be 1
            $status.Working.Modified.Count | Should -Be 1
            $status.Working.Unmerged.Count | Should -Be 1
            $status.Working.Added[0] | Should -Be "test/Untracked.Tests.ps1"
            $status.Working.Added[1] | Should -Be "test/Added.Tests.ps1"
            $status.Working.Deleted[0] | Should -Be "test/Deleted.Tests.ps1"
            $status.Working.Modified[0] | Should -Be "test/Modified.Tests.ps1"
            $status.Working.Unmerged[0] | Should -Be "test/Unmerged.Tests.ps1"
            $status.Index.Added.Count | Should -Be 1
            $status.Index.Deleted.Count | Should -Be 1
            $status.Index.Modified.Count | Should -Be 3
            $status.Index.Unmerged.Count | Should -Be 1
            $status.Index.Added[0] | Should -Be "test/Added.Tests.ps1"
            $status.Index.Deleted[0] | Should -Be "test/Deleted.Tests.ps1"
            $status.Index.Modified[0] | Should -Be "test/Copied.Tests.ps1"
            $status.Index.Modified[1] | Should -Be "README.md"
            $status.Index.Modified[2] | Should -Be "test/Modified.Tests.ps1"
            $status.Index.Unmerged[0] | Should -Be "test/Unmerged.Tests.ps1"
        }
        It 'Parses a status with many changed files' {
            # The status of a repository with many changed files is parsed
            # without a regular expression for every line, so that the prompt
            # does not take a long time to appear (#314).
            $manyFiles = 1..2000 | ForEach-Object { "1 .M N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 test/Modified$_.Tests.ps1" }

            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines ((@(
                    '# branch.oid 1111111111111111111111111111111111111111'
                    '# branch.head master'
                ) + $manyFiles) -join "`n")
            }

            $status = Get-GitStatus
            $status.Branch | Should -Be 'master'
            $status.Working.Modified.Count | Should -Be 2000
            $status.Working.Modified[0] | Should -Be 'test/Modified1.Tests.ps1'
            $status.Working.Modified[1999] | Should -Be 'test/Modified2000.Tests.ps1'
        }
        It 'Parses a path that contains a space' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
1 .M N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 test/Modified File.Tests.ps1
'@
            }

            $status = Get-GitStatus
            $status.Working.Modified.Count | Should -Be 1
            $status.Working.Modified[0] | Should -Be 'test/Modified File.Tests.ps1'
        }
    }

    Context 'Get-GitStatus porcelain version 2 tests' {
        BeforeAll {
            Set-Location $PSScriptRoot
        }

        It 'Returns the upstream and the number of commits the branch is ahead and behind' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
# branch.upstream origin/master
# branch.ab +2 -3
'@
            }

            $status = Get-GitStatus
            $status.Branch | Should -Be 'master'
            $status.Upstream | Should -Be 'origin/master'
            $status.AheadBy | Should -Be 2
            $status.BehindBy | Should -Be 3
            $status.UpstreamGone | Should -Be $false
        }

        It 'Reports a branch whose upstream is gone' {
            # Git does not report the number of commits the branch is ahead
            # and behind, when the upstream does not exist.
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
# branch.upstream origin/master
'@
            }

            $status = Get-GitStatus
            $status.Branch | Should -Be 'master'
            $status.Upstream | Should -Be 'origin/master'
            $status.AheadBy | Should -Be 0
            $status.BehindBy | Should -Be 0
            $status.UpstreamGone | Should -Be $true
        }

        It 'Does not use the marker of a detached HEAD as the branch' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                if ($args -contains 'symbolic-ref') {
                    return 'refs/heads/the-branch-of-the-worktree'
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head (detached)
'@
            }

            $status = Get-GitStatus
            # The branch is read from Git, because the status only says that
            # the HEAD is detached.
            $status.Branch | Should -Be 'the-branch-of-the-worktree'
            $status.Branch | Should -Not -Be '(detached)'
        }

        It 'Returns the branch of a repository without any commit' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid (initial)
# branch.head feature/x
'@
            }

            $status = Get-GitStatus
            $status.Branch | Should -Be 'feature/x'
        }

        It 'Parses a renamed file as the file that it was renamed from' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
2 R. N... 100644 100644 100644 2222222222222222222222222222222222222222 3333333333333333333333333333333333333333 R100 README2.md	README.md
'@
            }

            $status = Get-GitStatus
            $status.Index.Modified.Count | Should -Be 1
            $status.Index.Modified[0] | Should -Be 'README.md'
        }
    }

    Context 'Branch progress suffix' {
        BeforeEach {
            [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
            $repoPath = NewGitTempRepo -MakeInitialCommit
        }
        AfterEach {
            Set-Location $PSScriptRoot
            RemoveGitTempRepo $repoPath
        }

        It('Shows CHERRY-PICKING') {
            git checkout -qb test
            Write-Output 1 > test.txt
            git add test.txt
            git commit -qam 'first' 2> $null

            git checkout -qb conflict
            Write-Output 2 > test.txt
            git commit -qam 'second' 2> $null

            $status = Get-GitStatus
            $status.Branch | Should -Be conflict

            git cherry-pick test

            $status = Get-GitStatus
            $status.Branch | Should -Be 'conflict|CHERRY-PICKING'
        }

        It('Shows MERGING') {
            git checkout -qb test
            Write-Output 1 > test.txt
            git add test.txt
            git commit -qam 'first' 2> $null

            Write-Output 2 > test.txt
            git commit -qam 'second' 2> $null

            git checkout HEAD~ -qb conflict
            Write-Output 3 > test.txt
            git commit -qam 'third' 2> $null

            $status = Get-GitStatus
            $status.Branch | Should -Be conflict

            git merge test

            $status = Get-GitStatus
            $status.Branch | Should -Be 'conflict|MERGING'
        }

        It('Shows REVERTING') {
            git checkout -qb test
            Write-Output 1 > test.txt
            git add test.txt
            git commit -qam 'first' 2> $null

            git checkout -qb conflict
            Write-Output 2 > test.txt
            git commit -qam 'second' 2> $null

            $status = Get-GitStatus
            $status.Branch | Should -Be conflict

            git revert test

            $status = Get-GitStatus
            $status.Branch | Should -Be 'conflict|REVERTING'
        }
    }

    Context 'Git Status Cache Tests' {
        BeforeAll {
            Set-Location $PSScriptRoot
        }

        It 'Falls back to Git when the status cache is not available' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
? test/Foo.Tests.ps1
'@
            }

            # Simulate the GitStatusCachePoshClient module not being available.
            function global:Get-GitStatusFromCache {
                Get-ThisCommandDoesNotExist
            }
            try {
                Mock -ModuleName posh-git Get-GitStatusFromCache {
                    Get-ThisCommandDoesNotExist
                }

                $GitPromptSettings.EnableFileStatusFromCache = $true
                try {
                    $status = Get-GitStatus
                }
                finally {
                    $GitPromptSettings.EnableFileStatusFromCache = $null
                }
            }
            finally {
                Remove-Item function:global:Get-GitStatusFromCache -ErrorAction SilentlyContinue
            }

            $status.Branch | Should -Be 'master'
            $status.HasUntracked | Should -Be $true
            $status.Working.Added.Count | Should -Be 1
            $status.Working.Added[0] | Should -Be 'test/Foo.Tests.ps1'
        }

        It 'Falls back to Git when the status cache returns an error' {
            Mock -ModuleName posh-git git {
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
? test/Foo.Tests.ps1
'@
            }

            # Simulate the cache service not being reachable.
            function global:Get-GitStatusFromCache {
                [PSCustomObject]@{ Error = 'the cache service is not running' }
            }
            try {
                Mock -ModuleName posh-git Get-GitStatusFromCache {
                    [PSCustomObject]@{ Error = 'the cache service is not running' }
                }

                $GitPromptSettings.EnableFileStatusFromCache = $true
                try {
                    $status = Get-GitStatus
                }
                finally {
                    $GitPromptSettings.EnableFileStatusFromCache = $null
                }
            }
            finally {
                Remove-Item function:global:Get-GitStatusFromCache -ErrorAction SilentlyContinue
            }

            $status.Branch | Should -Be 'master'
            $status.Branch | Should -Not -Be 'CACHE ERROR'
            $status.HasUntracked | Should -Be $true
            $status.Working.Added.Count | Should -Be 1
            $status.Working.Added[0] | Should -Be 'test/Foo.Tests.ps1'
        }
    }

    Context 'Git Status Command Tests' {
        BeforeAll {
            Set-Location $PSScriptRoot
        }

        It 'Lets Git update the index when the status is computed' {
            $global:capturedGitArgs = @()

            Mock -ModuleName posh-git git {
                $global:capturedGitArgs = @($args)
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
'@
            }

            try {
                Get-GitStatus
            }
            finally {
                $capturedArgs = $global:capturedGitArgs
                Remove-Variable -Name capturedGitArgs -Scope Global -ErrorAction SilentlyContinue
            }

            # Git has to be able to refresh the index. Otherwise it has to
            # compare the content of every file on every call, which is very
            # slow for repositories with large files that are processed by a
            # clean filter (e.g. Git LFS).
            $capturedArgs | Should -Contain 'status'
            $capturedArgs | Should -Not -Contain '--no-optional-locks'
        }

        It 'Does not let Git update the index when AutoRefreshIndex is disabled' {
            $global:capturedGitArgs = @()

            Mock -ModuleName posh-git git {
                $global:capturedGitArgs = @($args)
                $OFS = " "
                if ($args -contains 'rev-parse') {
                    $res = Invoke-Expression "&$gitbin $args"
                    return $res
                }
                Convert-NativeLineEnding -SplitLines @'
# branch.oid 1111111111111111111111111111111111111111
# branch.head master
'@
            }

            try {
                $GitPromptSettings.AutoRefreshIndex = $false
                try {
                    Get-GitStatus
                }
                finally {
                    $GitPromptSettings.AutoRefreshIndex = $true
                }
            }
            finally {
                $capturedArgs = $global:capturedGitArgs
                Remove-Variable -Name capturedGitArgs -Scope Global -ErrorAction SilentlyContinue
            }

            $capturedArgs | Should -Contain 'status'
            $capturedArgs | Should -Contain '--no-optional-locks'
        }
    }

    Context 'Stash Status Tests' {
        BeforeAll {
            [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
            $repoPath = NewGitTempRepo -MakeInitialCommit
        }
        AfterAll {
            RemoveGitTempRepo $repoPath
        }
        AfterEach {
            &$gitbin stash clear *>$null
        }
        It 'Returns the number of stashes' {
            'change' | Out-File ./file.txt -Encoding ascii
            &$gitbin add ./file.txt *>$null
            &$gitbin stash push -m 'test stash' *>$null

            $GitPromptSettings.EnableStashStatus = $true
            try {
                $status = Get-GitStatus
            }
            finally {
                $GitPromptSettings.EnableStashStatus = $false
            }

            $status.StashCount | Should -Be 1
        }
        It 'Returns no stashes when there are none' {
            $GitPromptSettings.EnableStashStatus = $true
            try {
                $status = Get-GitStatus
            }
            finally {
                $GitPromptSettings.EnableStashStatus = $false
            }

            $status.StashCount | Should -Be 0
        }
    }

    Context 'In .git' {
        BeforeEach {
            [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
            $repoPath = NewGitTempRepo
        }
        AfterEach {
            Set-Location $PSScriptRoot
            RemoveGitTempRepo $repoPath
        }

        It('Does not have files') {
            New-Item "$repoPath/test.txt" -ItemType File

            $status = Get-GitStatus
            $status.HasUntracked | Should -Be $true
            $status.HasWorking | Should -Be $true
            $status.Working.Added.Count | Should -Be 1

            Set-Location "$repoPath/.git" -ErrorAction Stop

            $status = Get-GitStatus
            $status.HasUntracked | Should -Be $false
            $status.HasWorking | Should -Be $false
            $status.Working.Added.Count | Should -Be 0

            Set-Location "$repoPath/.git/refs" -ErrorAction Stop

            $status = Get-GitStatus
            $status.HasUntracked | Should -Be $false
            $status.HasWorking | Should -Be $false
            $status.Working.Added.Count | Should -Be 0
        }
    }

    Context 'In .github' {
        BeforeEach {
            [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
            $repoPath = NewGitTempRepo
            New-Item -Type Directory -Force "$repoPath/.github/workflows"
        }
        AfterEach {
            Set-Location $PSScriptRoot
            RemoveGitTempRepo $repoPath
        }

        It('Files are not ignored') {
            New-Item "$repoPath/test.txt" -ItemType File

            $status = Get-GitStatus
            $status.HasUntracked | Should -Be $true
            $status.HasWorking | Should -Be $true
            $status.Working.Added.Count | Should -Be 1

            Set-Location "$repoPath/.github" -ErrorAction Stop

            $status = Get-GitStatus
            $status.HasUntracked | Should -Be $true
            $status.HasWorking | Should -Be $true
            $status.Working.Added.Count | Should -Be 1

            Set-Location "$repoPath/.github/workflows" -ErrorAction Stop

            $status = Get-GitStatus
            $status.HasUntracked | Should -Be $true
            $status.HasWorking | Should -Be $true
            $status.Working.Added.Count | Should -Be 1
        }
    }
}
