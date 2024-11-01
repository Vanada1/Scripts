<#
.SYNOPSIS
Creates a template for module files.

.DESCRIPTION
Creates a template for module files. The template includes .psm1 and .psd1 files, as well as Public and Private folders.
The module is collected in its own folder under a specific version.

.PARAMETER OutputPath
The path to create the module template.

.PARAMETER ModuleName
Module name.

.PARAMETER ModuleVersion
Module version.

.PARAMETER Author
Author of the created module.

.PARAMETER PSVersion
PowerShell version.

.EXAMPLE
$modulePath = New-ModuleTemplate -ModuleName 'MyModule' -ModuleVersion "1.0.0.0" -Author "Me" -PSVersion '7.0' -OutputPath 'C:\'
#>
Function New-ModuleTemplate {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,

        [Parameter(Mandatory = $true)]
        [string]$ModuleName,

        [Parameter(Mandatory = $true)]
        [string]$ModuleVersion,

        [Parameter(Mandatory = $true)]
        [string]$Author,

        [Parameter(Mandatory = $true)]
        [string]$PSVersion
    )

    $oldLocation = Get-Location
    $modulePath = Join-Path $OutputPath "$($ModuleName)\$($ModuleVersion)"
    Write-Verbose "Creating directory $modulePath"
    New-Item -Path $modulePath -ItemType Directory
    Write-Verbose "Moving to directory $modulePath"
    Set-Location $modulePath

    $manifestParameters = @{
        ModuleVersion     = $ModuleVersion
        Author            = $Author
        Path              = ".\$($ModuleName).psd1"
        RootModule        = ".\$($ModuleName).psm1" 
        PowerShellVersion = $PSVersion
    }
    Write-Verbose "Creating module manifest $manifestParameters"
    New-ModuleManifest @manifestParameters

    Write-Verbose "Creating file $($ModuleName).psm1"
    $file = @{ 
        Path     = ".\$($ModuleName).psm1"
        Encoding = 'utf8'
    }
    Out-File @file
    @'
$public = Join-Path $PSScriptRoot 'Public'
$private = Join-Path $PSScriptRoot 'Private'
$Functions = Get-ChildItem -Path $public, $private -Filter '*.ps1'

Foreach ($import in $Functions) {
    Try {
    Write-Verbose "dot-sourcing file '$($import.fullname)'"
    . $import.fullname
    }
    Catch {
    Write-Error -Message "Failed to load function $($import.name)"
    }
}
'@ | Add-Content $file.Path

    New-Item -Path './Public' -ItemType Directory
    New-Item -Path './Private' -ItemType Directory

    Write-Verbose "Moving back to $oldLocation"
    Set-Location $oldLocation

    $modulePath
}