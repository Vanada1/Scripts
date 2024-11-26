Function New-SoftwareVersion {
    [CmdletBinding()]
    [OutputType([string])]

    param (
        [Parameter(Mandatory = $true)]
        [string]$LastVersion,

        [Parameter(Mandatory = $true)]
        [string]$IncrementVersionType,
        
        # TODO: Возможно, вместо использования только релиза кандидата, использовать более гибкую структуру,
        # чтобы можно было работать с другими вариантами версий (например, alpha или beta релизы)
        [Parameter(Mandatory = $false)]
        [switch]$ReleaseCandidate,

        [Parameter(Mandatory = $false)]
        [int]$ReleaseCandidateLastVersion,

        [Parameter(Mandatory = $false)]
        [switch]$Build,
        
        [Parameter(Mandatory = $false)]
        [int]$BuildVersion
    )

    $availableIncrementVersionType = @(
        'Major', 'Minor', 'Patch', 'ReleaseCandidate', 'M', 'm', 'p', 'rc')

    if (-not $availableIncrementVersionType.Contains($IncrementVersionType)) {
        Write-Error "$IncrementVersionType is not available version type. You must use the following available types: $availableIncrementVersionType" -ErrorAction Stop
    }

    # Условия для установки версий https://semver.org/
    $regexString = '^(?<major>\d+)\.(?<minor>\d+).(?<patch>\d+)+(?<pre_release>(\-\w+\.\d+)?)(\+(?<build>\d+))?$'
    $newVersion = ''

    if ($IncrementVersionType -eq 'Major' -or $IncrementVersionType -eq 'M') {

    }
    
    if ($IncrementVersionType -eq 'Minor' -or $IncrementVersionType -eq 'm') {
        
    }
    
    if ($IncrementVersionType -eq 'Patch' -or $IncrementVersionType -eq 'p') {
        
    }

    if ($ReleaseCandidate -and ($IncrementVersionType -eq 'ReleaseCandidate' -or $IncrementVersionType -eq 'rc')) {
        
    }

    if ($Build) {
        $newVersion += "+$BuildVersion"
    }

    $newVersion
}