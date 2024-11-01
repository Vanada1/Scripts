<#
.SYNOPSIS
Returns information about installed applications.

.DESCRIPTION
Searches the registry along the path SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall for the sent PC name for all installed applications.
After which it takes all the necessary applications that are located in a certain directory if the $Directories parameter was set.

.PARAMETER PCName
The name of the PC on which installed applications will be searched.

.PARAMETER Directories
An array of paths along which the required installed applications will be selected.

.EXAMPLE
Get-InstalledApplication -PCName -Directories 'C:\', 'D:\'
#>
Function Get-InstalledApplication {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PCName,

        [Parameter(Mandatory = $false)]
        [string[]]$Directories
    )

    Write-Verbose "PC name: $PCName"
    if ($Directories) {
        Write-Verbose "Searching directories: $Directories"
    }
    else {
        Write-Verbose "Searching directories in whole PC"        
    }

    $uninstallKey = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
    $reg = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine', $PCName)
    $regkey = $reg.OpenSubKey($uninstallKey) 
    $subkeys = $regkey.GetSubKeyNames() 
    $intallPathValueNames = 'InstallSource', 'InstallLocation'
    $array = @()
    foreach ($key in $subkeys) {
        $thisKey = $uninstallKey + "\\" + $key 
        Write-Verbose "Getting info from $thisKey"

        $thisSubKey = $reg.OpenSubKey($thisKey)
        $valueNames = $thisSubKey.GetValueNames() 

        Write-Verbose "Creating new object"
        $object = New-Object PSObject

        Write-Verbose "Adding member `"ComputerName`" with value `"$PCName`""
        $object | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $PCName
        $isAdding = -not $Directories
        foreach ($valueName in $valueNames) {
            $value = $thisSubKey.GetValue($valueName)
            if (-not $value) {
                continue
            }

            if ($intallPathValueNames.Contains($valueName)) {
                foreach ($directory in $Directories) {
                    if ($value.Contains($directory)) {
                        $isAdding = $true
                    }
                }
            }

            Write-Verbose "Adding member `"$valueName`" with value `"$value`""
            $object | Add-Member -MemberType NoteProperty -Name $valueName -Value $value
        }

        if ($isAdding) {
            Write-Verbose "Adding new object to array"
            $array += $object
        }
    } 

    $array
}
