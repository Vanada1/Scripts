<#
.SYNOPSIS
Deletes files that have already been archived.

.DESCRIPTION
Opens the archive, after which it goes through each file in the archive and compares it with the sent files. If the sent file was found in the archive, it is deleted.

.PARAMETER ZipFile
Path to the archive.

.PARAMETER FilesToDelete
Files that need to be deleted.

.PARAMETER WhatIf
Checks whether files can be deleted without directly deleting them.

.EXAMPLE
$files = Get-ChildItem -Path 'C:\Logs' -File
Remove-ArchivedFiles -ZipFile 'C:\Temp\archive.zip' -FilesToDelete $files
#>
Function Remove-ArchivedFiles {
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ZipFile,

        [Parameter(Mandatory = $true)]
        [object]$FilesToDelete,

        [Parameter(Mandatory = $false)]
        [switch]$WhatIf = $false
    )

    $AssemblyName = 'System.IO.Compression.FileSystem'
    Add-Type -AssemblyName $AssemblyName | Out-Null
    $OpenZip = [System.IO.Compression.ZipFile]::OpenRead($ZipFile)
    $ZipFileEntries = $OpenZip.Entries
    foreach ($file in $FilesToDelete) {
        $check = $ZipFileEntries | Where-Object { $_.Name -eq $file.Name -and
            $_.Length -eq $file.Length }
        if ($null -ne $check) {
            $file | Remove-Item -Force -WhatIf:$WhatIf
        }
        else {
            Write-Error "File '$($file.Name)' not found in '$($ZipFile)'"
        }
    }
}
