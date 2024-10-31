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
        foreach ($valueName in $valueNames) {
            $value = $thisSubKey.GetValue($valueName)
            if (-not $value) {
                continue
            }

            Write-Verbose "Adding member `"$valueName`" with value `"$value`""
            $object | Add-Member -MemberType NoteProperty -Name $valueName -Value $value
        }

        Write-Verbose "Adding new object to array"
        $array += $object
    } 

    $array
}


$InstalledApplicationParameters = @{
    # PCName = Invoke-Expression -Command 'hostname'
    PCName = $env:ComputerName
}
Get-InstalledApplication @InstalledApplicationParameters