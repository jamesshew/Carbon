# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Write-Verbose -Message ('=' * 70) -Verbose
Write-Verbose -Message ($PSVersionTable.PSVersion) -Verbose
Get-Module 'ServerManager' | Out-String | Write-Verbose
Get-WmiObject -List -Class Win32_OptionalFeature | Out-String | Write-Verbose -Verbose
Write-Verbose -Message ('=' * 70) -Verbose

if( $PSVersionTable.PSVersion -gt [Version]'2.0' -and -not (Get-Module 'ServerManager') -and (Get-WmiObject -List -Class Win32_OptionalFeature) )
{
    function Start-TestFixture
    {
        & (Join-Path -Path $PSScriptRoot -ChildPath '..\Import-CarbonForTest.ps1' -Resolve)
    }

    function Test-ShouldDetectInstalledFeature
    {
        Get-WindowsFeature | 
            Where-Object { $_.Installed } |
            Select-Object -First 1 |
            ForEach-Object {
                Assert-True (Test-WindowsFeature -Name $_.Name -Installed) $_.Name
            }
    }

    function Test-ShouldDetectUninstalledFeature
    {
        Get-WindowsFeature | 
            Where-Object { -not $_.Installed } |
            Select-Object -First 1
            ForEach-Object {
                Assert-False (Test-WindowsFeature -Name $_.Name -Installed) $_.Name
            }
    }

    function Test-ShouldDetectFeatures
    {
        Get-WindowsFeature |
            Select-Object -First 1 |
            ForEach-Object { Assert-True (Test-WindowsFeature -Name $_.Name) $_.Name }
    }

    function Test-ShouldNotDetectFeature
    {
        Assert-False (Test-WindowsFeature -Name 'IDoNotExist')
    }
}
else
{
    Write-Warning "Tests for Test-WindowsFeature not supported on this operating system."
}

