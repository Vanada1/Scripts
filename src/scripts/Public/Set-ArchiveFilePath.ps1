<#
.SYNOPSIS
Creates a path for a new archive.

.DESCRIPTION
Creates a path for a new archive.

.PARAMETER ZipPath
Path where the archive should be located.

.PARAMETER ZipPrefix
The starting line (prefix) for the archive name.

.PARAMETER Date
The date that will be set for the archive name.

.EXAMPLE
Set-ArchiveFilePath -ZipPath 'C:\Temp' -ZipPrefix 'my_archive'
#>
Function Set-ArchiveFilePath { 
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ZipPath,

        [Parameter(Mandatory = $true)]
        [string]$ZipPrefix,

        [Parameter(Mandatory = $false)]
        [datetime]$Date = (Get-Date)
    )

    if (-not (Test-Path -Path $ZipPath)) {
        New-Item -Path $ZipPath -ItemType Directory | Out-Null
        Write-Verbose "The '$ZipPath' folder has been created"
    }

    $ZipName = "$($ZipPrefix)$($Date.ToString('yyyyMMdd')).zip"
    $ZipFile = Join-Path $ZipPath $ZipName
    if (Test-Path -Path $ZipFile) {
        throw "File '$ZipFile' already exists"
    }

    $ZipFile
}
