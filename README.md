# Scripts

## Сode style

### Правила именования и применения стилей
Глагол лучше всего выбрать из утвержденного списка, который можно просмотреть при помощи команды [`Get-Verb`](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/09-functions?view=powershell-7.4). Существительное должно быть в единственном числе (например, `Get-Command`, а не `Get-Commands`).
```powershell
<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Do-Something{
    [CmdletBinding()]
    [OutputType([<#Type#>])]
    param(
        [Parameter(Mandatory = $true)]
        [<#Type#>]$param1,
        
        [Parameter(Mandatory = $false)]
        [<#Type#>]$param2,
    )
}
```

Имена модулей, параметров и переменных пишутся, как принято в **Pascal**: каждое слово в составе имени начинается с большой буквы. Например, только что созданный модуль мы назвали `FileCleanupTools`.

Использовать описательные имена. Например, параметр `$NumberOfDays` будет иметь лучшее название, чем просто `$Days`.