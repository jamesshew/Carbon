# Copyright 2012 Aaron Jensen
# 
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

function Start-TestFixture
{
    & (Join-Path -Path $PSScriptRoot -ChildPath '..\Carbon\Import-Carbon.ps1' -Resolve)
}

function Test-AllFunctionsShouldHaveDocumentation
{
	$commandsMissingDocumentation = Get-Command -Module Carbon | 
                                        Where-HelpIncomplete |  
                                        Select-Object -ExpandProperty Name | 
                                        Sort-Object
    Assert-NoDocumentationMissing $commandsMissingDocumentation
}

function Test-AllDscResourcesShouldHaveDocumentation
{
    $dscRoot = Join-Path -Path $PSScriptRoot -ChildPath '..\Carbon\DscResources' -Resolve
    $resourcesMissingDocs = @()
    
    foreach( $resourceRoot in (Get-ChildItem -Path $dscRoot -Directory -Filter 'Carbon_*') )
    {
        Import-Module -Name $resourceRoot.FullName
        $moduleName = $resourceRoot.Name
        try
        {
            $resourcesMissingDocs += Get-Command -Name 'Set-TargetResource' -Module $moduleName | 
                                        Where-HelpIncomplete | 
                                        Select-Object -ExpandProperty Module | 
                                        Select-Object -ExpandProperty Name | 
                                        Sort-Object
        }
        finally
        {
            Remove-Module $moduleName
        }
    }

    Assert-NoDocumentationMissing $resourcesMissingDocs
}

function Assert-NoDocumentationMissing
{
    param(
        [string[]]
        $CommandName
    )

    Set-StrictMode -Version 'Latest'

    if( $CommandName )
    {
        $errorMsg = "The following commands are missing all or part of their documentation:`n`t{0}" -f ($CommandName  -join "`n`t")
        Fail $errorMsg
    }
}

filter Where-HelpIncomplete
{
    param(
        [Parameter(ValueFromPipeline=$true)]
        [Management.Automation.CommandInfo]
        $Command
    )

    Set-StrictMode -Version 'Latest'

    $_ | 
        #Where-Object { $_.Name -ne 'New-TempDir' } |
        Where-Object { 
    		$help = $_ | Get-Help 
            if( $help -is [String] )
            {
                return $true
            }

            if( -not (($help | Get-Member 'synopsis') -and ($help | Get-Member 'description') -and ($help | Get-Member 'examples')) )
            {
                return $true
            }

            return -not ($help.synopsis -and $help.description -and $help.examples)
        } 
}