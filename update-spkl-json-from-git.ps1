param(
    [string]$Root = "js",
    [string]$SpklFile = "../spkl.json",
    [switch]$UseMinified
)

# CRM webresource prefix
$resourcePrefix = "xyz_"
# Publish flag for each webresource
$publish = $true
# Type 3 = JS resource
$resourceType = 3
# If true, displayname = uniquename
$displayNameAsUniquename = $true

if (!(Test-Path $SpklFile)) {
    Write-Error "$SpklFile not found"
    exit 1
}

# Read and parse spkl.json
$spklObj = Get-Content $SpklFile -Raw | ConvertFrom-Json
if (-not $spklObj.webresources -or $spklObj.webresources.Count -eq 0) {
    Write-Error "spkl.json does not contain a 'webresources' section"
    exit 1
}

# Get all changed .ts files (unstaged, staged, and in last commit)
$diffUncommitted = git diff --name-only HEAD
$diffLastCommit = git show --pretty="" --name-only HEAD

$allChangedFiles = @($diffUncommitted + $diffLastCommit) |
Where-Object { $_ -like "*.ts" }

Write-Host "`nDetected TS files in (unstaged, staged, last commit):"
$allChangedFiles | ForEach-Object { Write-Host "  $_" }

$filesArr = @()

if (-not $allChangedFiles -or $allChangedFiles.Count -eq 0) {
    foreach ($wr in $spklObj.webresources) {
        $wr.root = $Root
        $wr.files = @()
    }
    $spklObj | ConvertTo-Json -Depth 10 | Out-File $SpklFile -Encoding utf8
    Write-Host "`nNo changed TS files in git diff/show. Files section cleared."
    exit 0
}

foreach ($f in $allChangedFiles) {
    $fname = Split-Path $f -Leaf
    $relPath = $f.Substring($Root.Length + 1) -replace '\.ts$', ''
    $base = $fname -replace '\.ts$', ''

    if ($UseMinified) {
        $relJs = "$relPath.min.js"
    } else {
        $relJs = "$relPath.js"
    }

    $crmname = "$resourcePrefix$base"
    $entry = @{
        uniquename = $crmname
        file = $relJs
        type = $resourceType
        publish = $publish
    }
    if ($displayNameAsUniquename) {
        $entry.displayname = $crmname
    }
    $filesArr += $entry
}

$spklObj.webresources[0].root  = $Root
$spklObj.webresources[0].files = $filesArr

$spklObj | ConvertTo-Json -Depth 10 | Out-File $SpklFile -Encoding utf8
Write-Host "`nUpdated $SpklFile with $($filesArr.Count) file(s) from git diff."
