<#
.SYNOPSIS
Recursively searches files with a specified extension in a directory, finds strings from a search terms file, and saves results to an output file.

.DESCRIPTION
This script recursively processes files with the extension specified in the `Format` parameter within a given directory.
 For each file, it checks for the presence of strings from a search terms file (case-insensitive).
  Results are written to an output file in the format: filename + matched lines. Files without matches are excluded.

.PARAMETER InputPath
The directory path to recursively search for files. Required.

.PARAMETER SearchTermsPath
The path to a text file containing search terms (one per line). Required.

.PARAMETER OutputPath
The path to save the output file containing results. Required.

.PARAMETER Format
The file extension to search for (e.g., `.txt`, `*.log`). Required. Must start with a dot (`.`).

.EXAMPLE
.\FindStringsInFiles.ps1 -InputPath "C:\Projects" -SearchTermsPath "C:\search_terms.txt" -OutputPath "C:\results.txt" -Format ".txt"
Searches `.txt` files in `C:\Projects`, checks for strings from `search_terms.txt`, and saves results to `results.txt`.

.NOTES
- Empty lines in the search terms file are ignored.
- Matches are case-insensitive.
- Only files with at least one match are included in the output.
#>
Function Find-StringsInFiles {
    # TODO: We need to separate saving and searching into different functions.
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$InputPath,

        [Parameter(Mandatory = $true)]
        [string]$SearchTermsPath,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath,

        [Parameter(Mandatory = $true)]
        [string]$Format
    )

    Write-Verbose "Checking the existence of paths..."
    if (-not (Test-Path -Path $InputPath)) {
        throw "Error: Path $InputPath does not exist."
    }

    if (-not (Test-Path -Path $SearchTermsPath)) {
        throw "Error: File with searched strings $SearchTermsPath does not exist."
    }

    Write-Verbose "Reading the search strings..."
    $searchTerms = Get-Content -Path $SearchTermsPath |
    Where-Object { $_ -match '\S' } |
    ForEach-Object { $_.Trim() }

    if ($searchTerms.Count -eq 0) {
        throw "Error: The file with the searched lines is empty."
    }

    Write-Verbose "Getting all files under the filter $Format"
    $files = Get-ChildItem -Path $InputPath -Recurse -Filter "*$Format"
    $results = @()
    foreach ($file in $files) {
        Write-Verbose "Processing '$($file.FullName)'..."
        $content = Get-Content -Path $file.FullName
        $matchStrings = @()

        for ($i = 0; $i -lt $content.Length; $i++) {
            $line = $content[$i]

            foreach ($term in $searchTerms) {
                # Ignore case and look for exact match (not regular expression)
                # Case-sensitive string checking may be needed
                if ($line -imatch [regex]::Escape($term)) {
                    $matchStrings += [PSCustomObject]@{
                        LineNumber = $i + 1
                        LineText   = $line
                    }
                    break
                }
            }
        }

        Write-Verbose "The file had $($matchStrings.Count) matches found."
        if ($matchStrings.Count -gt 0) {
            $results += [PSCustomObject]@{
                FileName = $file.FullName
                Matches  = $matchStrings
            }
        }
    }

    Write-Verbose "The final conclusion is formed."
    $outputLines = @()

    for ($i = 0; $i -lt $results.Count; $i++) {
        $file = $results[$i]
        $outputLines += $file.FileName

        foreach ($match in $file.Matches) {
            $outputLines += "$($match.LineNumber). $($match.LineText)"
        }

        if ($i -ne $results.Count - 1) {
            $outputLines += ""
        }
    }

    Write-Verbose "Save the result to a file '$OutputPath'"
    $outputLines | Out-File -FilePath $OutputPath -Encoding UTF8

    Write-Host "✅ The results are successfully saved in the file: $OutputPath"
}