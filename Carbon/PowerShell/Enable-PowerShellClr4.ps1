function Enable-PowerShellClr4
{
    <#
    .SYNOPSIS  
    Configures PowerShell 2 to use the .NET 4.0 framework, if it is installed.

    .DESCRIPTION
    **THIS SHOULD BE CONSIDERED A FEATURE OF LAST RESORT.  YOU'VE BEEN WARNED.**  Try using `Invoke-PowerShell` if you just need to run a snippet of code with .NET 4.  It's a bad idea to permanently enable .NET 4 on a machine or across multiple machines.  If you need .NET 4, upgrade to PowerShell v3.

    Creates a configuration file in the PowerShell directory (i.e. `$pshome`) that tells PowerShell that the .NET 4.0 CLR is supported.  When launched, PowerShell will then use the .NET 4 CLR, if it is installed.  
    
    If you're running PowerShell v3 or greater, this function does nothing.

    .LINK
    Invoke-PowerShell
    
    .EXAMPLE
    Enable-PowerShellClr4 -Console -ISE
    
    Configures PowerShell and the PowerShell ISE to use the .NET 4 framework if it is installed.
    #>
    
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Switch]
        # Enables the .NET 4.0 CLR for the PowerShell console, e.g. `powershell.exe`.
        $Console,

        [Switch]
        # Enables the .NET 4.0 CLR for the PowerShell ISE, e.g. `powershell_ise.exe`.
        $Ise,

        [Switch]
        # Overwrites the PowerShell config file.
        $Force
    )

    # Don't do anything if already running .NET 4 or higher.
    if( $PSVersionTable.CLRVersion -ge '4.0' )
    {
        return
    }

    function Set-PowerShellConfigFile
    {
        param(
            $Path
        )

        if( -not $Force -and (Test-Path -Path $Path -PathType Leaf) )
        {
            Write-Error ('Failed to enable .NET 4: PowerShell config file ''{0}'' exists.  Use the -Force switch to overwrite.' -f $Path)
            return
        }
        else
        {
            @'
<?xml version="1.0"?>
<configuration>
    <startup useLegacyV2RuntimeActivationPolicy="true">
        <supportedRuntime version="v4.0.30319"/>
        <supportedRuntime version="v2.0.50727"/>
    </startup>
</configuration>
'@ | Out-File -FilePath $Path -Encoding OEM
        }
    }

    if( $Console )
    {
        Write-Warning ('Enabling .NET 4.  Restart any PowerShell consoles/processes to start using .NET 4.')
        Set-PowerShellConfigFile -Path (Join-Path $PSHOME powershell.exe.config)

    }

    if( $Ise )
    {
        Write-Warning ('Enabling .NET 4.  Restart any PowerShell ISE programs to start using .NET 4.')
        Set-PowerShellConfigFile -Path (Join-Path $PSHOME powershell_ise.exe.config)
    }
}