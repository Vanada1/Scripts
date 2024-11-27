<#
.SYNOPSIS
Increases the application version.

.DESCRIPTION
Increases the application version. When sending the current version,
you can choose which part of the version you want to increase (if necessary).
You can also install the pre-release version or the build version, or both.

.PARAMETER CurrentVersion
Current application version.

.PARAMETER IncrementVersionType
The type of version being modified. Can be Major, Minor or Patch.

.PARAMETER PreRelease
Adding a pre-release version.

.PARAMETER PreReleaseVersion
Meaning of pre-release version.

.PARAMETER Build
Adding a build number.

.PARAMETER BuildVersion
Build number value.

.EXAMPLE
New-SoftwareVersion -CurrentVersion '1.0.0'
New-SoftwareVersion -CurrentVersion '1.0.0' -IncrementVersionType 'Major'
New-SoftwareVersion -CurrentVersion '1.0.0' -IncrementVersionType 'Minor'
New-SoftwareVersion -CurrentVersion '1.0.0' -IncrementVersionType 'Patch'
New-SoftwareVersion -CurrentVersion '1.0.0' -PreRelease -PreReleaseVersion 'rc.1'
New-SoftwareVersion -CurrentVersion '1.0.0' -PreRelease -PreReleaseVersion 'rc.1' -Build '1234567'
New-SoftwareVersion -CurrentVersion '1.0.0' -IncrementVersionType 'Major' -PreRelease -PreReleaseVersion 'rc.1' -Build '1234567'

.NOTES
Conditions for installing versions of https://semver.org/
#>
Function New-SoftwareVersion {
    [CmdletBinding()]
    [OutputType([string])]

    param (
        [Parameter(Mandatory = $true)]
        [string]$CurrentVersion,

        [Parameter(Mandatory = $false)]
        [string]$IncrementVersionType,
        
        [Parameter(Mandatory = $false)]
        [switch]$PreRelease,

        [Parameter(Mandatory = $false)]
        [string]$PreReleaseVersion,

        [Parameter(Mandatory = $false)]
        [switch]$Build,
        
        [Parameter(Mandatory = $false)]
        [string]$BuildVersion
    )

    $regexString = '(?<major>(0|[1-9]\d*))\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*)(?:-(?<pre_release>(?:[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)))?(?:\+(?<build>(?:[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)))?'
    $matches = [regex]::Matches($CurrentVersion, $regexString)
    $match = $matches[0]

    $major = [int]$match.Groups['major'].Value
    $minor = [int]$match.Groups['minor'].Value
    $patch = [int]$match.Groups['patch'].Value

    if ($IncrementVersionType -eq 'Major') {
        $major += 1
        $minor = 0
        $patch = 0
    }
    
    if ($IncrementVersionType -eq 'Minor') {
        $minor += 1
        $patch = 0
    }
    
    if ($IncrementVersionType -eq 'Patch') {
        $patch += 1
    }

    $newVersion = "$major.$minor.$patch"
    if ($PreRelease) {
        $newVersion += "-$PreReleaseVersion"
    }

    if ($Build) {
        $newVersion += "+$BuildVersion"
    }

    $newVersion
}