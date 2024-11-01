<#
.SYNOPSIS
Recursively copies all files in a directory.

.DESCRIPTION
Recursively copies all files in a directory.

.PARAMETER FromDirectory
Path FROM which the files will be copied.

.PARAMETER ToDirectory
Path WHERE files will be copied.

.EXAMPLE
Copy-File -FromDirectory 'C:\Temp' -ToDirectory 'D:\Temp'
#>
Function Copy-File {
    [CmdletBinding()]
    [OutputType()]

    param (
        [Parameter(Mandatory = $true)]
        [string]$FromDirectory,
        
        [Parameter(Mandatory = $true)]
        [string]$ToDirectory
    )

    if (-not (Test-Path $ToDirectory)) {
        Write-Verbose "Creating directory $ToDirectory"
        New-Item -Path $ToDirectory -ItemType Directory
    }

    Write-Verbose "Getting all files $FromDirectory"
    $files = Get-ChildItem $FromDirectory -Recurse -File
    $root = Get-Location

    Write-Verbose "Moving to location $FromDirectory"
    Set-Location $FromDirectory
    foreach ($file in $files) {
        Write-Verbose "Coppying file $file"
        [string]$filePath = ($file | Resolve-Path -Relative)    
        $relativePath = $filePath.substring(2)
        $coppingPath = "$ToDirectory\$relativePath"
        Set-Location $root
        Write-Output $coppingPath
        New-Item -ItemType File -Path $coppingPath -Force
        $file | Copy-Item -Destination $coppingPath -Force
        Set-Location $FromDirectory
    }
    
    Write-Verbose "Back to location $FromDirectory"
    Set-Location $root    
}