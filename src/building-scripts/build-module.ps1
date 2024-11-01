[CmdletBinding()]
[OutputType()]

$ErrorActionPreference = 'Stop'
$buildModuleScriptPath = $PSScriptRoot

Write-Verbose 'Import New-ModuleTemplate.ps1'
$newModuleTemplate = Join-Path $buildModuleScriptPath 'New-ModuleTemplate.ps1'
. $newModuleTemplate

$module = @{
    ModuleName    = 'MyTools'
    ModuleVersion = "1.0.0.0"
    Author        = "Vladimir Shvoev"
    PSVersion     = '7.0'
    OutputPath    = 'E:\Code\Scripts\Scripts\src\building-scripts\release'
}
$modulePath = New-ModuleTemplate @module
if ($modulePath -is [array]) {
    $modulePath = $modulePath[0]
}

$scriptsPath = Join-Path $buildModuleScriptPath '../scripts'
$coppyFileScriptPath = Join-Path $scriptsPath 'Public/Copy-File.ps1'
. $coppyFileScriptPath

$copyFile = @{
    FromDirectory = $scriptsPath
    ToDirectory   = $modulePath
}
Copy-File @copyFile
