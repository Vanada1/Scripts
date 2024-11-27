<#
.SYNOPSIS
Walks through a directory and writes all the files that are in the directory to a file.

.DESCRIPTION
Walks through a directory and writes all the files that are in the directory to a file.

.PARAMETER Directory
The directory in which all files will be collected.

.PARAMETER SaveFilePath
Path to the file in which the information should be saved.

.PARAMETER Include
Templates for including files in the result.

.PARAMETER Recurse
Use a recursive path through the directory.

.PARAMETER Append
Append data instead of overwriting the file.

.PARAMETER UseRelativePath
Using relative paths.
#>
Function Save-FilesInDirectory {
    [CmdletBinding()]
    [OutputType()]

    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory,

        [Parameter(Mandatory = $true)]
        [string]$SaveFilePath,

        [Parameter(Mandatory = $false)]
        [string[]]$Include,

        [Parameter(Mandatory = $false)]
        [switch]$Recurse,

        [Parameter(Mandatory = $false)]
        [switch]$Append,

        [Parameter(Mandatory = $false)]
        [switch]$UseRelativePath
    )

    $getChildItem = @{
        Path = $Directory
        Recurse = $Recurse
        File = $true
        Include = $Include
    }

    $result = Get-ChildItem @getChildItem
    if ($UseRelativePath) {
        $resolvePath = @{
            Path             = $result
            Relative         = $true
            RelativeBasePath = $Directory
        }
        $result = Resolve-Path @resolvePath
    }

    if (-not (Test-Path $SaveFilePath)) {
        $directoryPath = Split-Path -Path $SaveFilePath -ErrorAction Stop
        if (-not(Test-Path $directoryPath)) {
            New-Item -ItemType Directory -Path $directoryPath -Force -ErrorAction Stop     
        }

        New-Item -ItemType File -Path $SaveFilePath -ErrorAction Stop
    }

    $content = @{
        Path  = $SaveFilePath
        Value = $result
    }
    if ($Append) {
        Add-Content @content
    }
    else {
        Set-Content @content
    }
}