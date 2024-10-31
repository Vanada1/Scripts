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
        $isAdding = $true -and -not $Directories
        foreach ($valueName in $valueNames) {
            $value = $thisSubKey.GetValue($valueName)
            if (-not $value) {
                continue
            }

            if ($Directories) {
                if ($intallPathValueNames.Contains($valueName)) {
                    foreach ($directory in $Directories) {
                        if ($value.Contains($directory)) {
                            $isAdding = $true
                        }
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


$InstalledApplicationParameters = @{
    PCName      = $env:ComputerName
    Directories = 'D:\', 'C:\'
}
Get-InstalledApplication @InstalledApplicationParameters