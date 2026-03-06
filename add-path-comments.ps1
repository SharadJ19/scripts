param(
    [string]$SrcPath = "src",
    [switch]$Preview,
    [switch]$ForceUpdate,
    [switch]$Remove,
    [switch]$Verbose
)

Clear-Host
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Angular Comment-Aware Path Injector" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# Prevent conflicting flags
if ($Remove -and $ForceUpdate) {
    Write-Host "ERROR: Cannot use -Remove and -ForceUpdate together." -ForegroundColor Red
    return
}

if (!(Test-Path $SrcPath)) {
    Write-Host "ERROR: src folder not found." -ForegroundColor Red
    return
}

$files = Get-ChildItem -Path $SrcPath -Recurse -File -Include *.ts,*.html,*.css,*.scss |
Where-Object {
    $_.FullName -notmatch "\\(node_modules|dist|\.angular|\.git|assets)\\"
}

if ($files.Count -eq 0) {
    Write-Host "No matching files found." -ForegroundColor Yellow
    return
}

$total = $files.Count
$count = 0
$added = 0
$updated = 0
$skipped = 0

$rootResolved = (Resolve-Path $SrcPath).Path

# Multiline + cross-platform safe PATH regex
$pathRegex = '(?m)^\s*(//|/\*|<!--)\s*PATH:\s*src[\\/].*?(-->|\*/)?\s*$'

foreach ($file in $files) {

    $count++
    Write-Progress -Activity "Processing files" `
                   -Status "$count of $total" `
                   -PercentComplete ([int](($count/$total)*100))

    $relativePath = $file.FullName.Substring($rootResolved.Length + 1)

    # Normalize to forward slash for injection consistency
    $relativePathNormalized = $relativePath -replace '\\','/'

    # Determine expected comment format
    switch ($file.Extension.ToLower()) {
        ".ts"   { $expected = "// PATH: src/$relativePathNormalized" }
        ".css"  { $expected = "/* PATH: src/$relativePathNormalized */" }
        ".scss" { $expected = "/* PATH: src/$relativePathNormalized */" }
        ".html" { $expected = "<!-- PATH: src/$relativePathNormalized -->" }
        default { continue }
    }

    $raw = Get-Content $file.FullName -Raw

    # -------------------------
    # REMOVE MODE
    # -------------------------
    if ($Remove) {

        if ($raw -match $pathRegex) {

            $newContent = [regex]::Replace($raw, $pathRegex, '', 1)
            $newContent = $newContent.TrimStart("`r","`n")

            if (-not $Preview) {
                Set-Content $file.FullName $newContent
            }

            $updated++
        }
        else {
            $skipped++
        }

        if ($Verbose) {
            Write-Host "$relativePath processed"
        }

        continue
    }

    # -------------------------
    # INJECTION / UPDATE MODE
    # -------------------------

    # Check first 5 lines only
    $lines = $raw -split "`r?`n"
    $topLimit = [Math]::Min(5, $lines.Count)
    $topBlock = ($lines[0..($topLimit-1)] -join "`n")

    $existingMatch = $topBlock -match 'PATH:\s*src[\\/]'

    if ($existingMatch) {

        if ($topBlock -match [regex]::Escape($expected)) {
            $skipped++
        }
        elseif ($ForceUpdate) {

            $newContent = [regex]::Replace($raw, $pathRegex, '', 1)
            $newContent = $expected + "`r`n" + $newContent.TrimStart("`r","`n")

            if (-not $Preview) {
                Set-Content $file.FullName $newContent
            }

            $updated++
        }
        else {
            $skipped++
        }

    }
    else {

        $newContent = $expected + "`r`n" + $raw

        if (-not $Preview) {
            Set-Content $file.FullName $newContent
        }

        $added++
    }

    if ($Verbose) {
        Write-Host "$relativePath processed"
    }
}

Write-Progress -Activity "Processing files" -Completed

Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host " Operation Complete" -ForegroundColor Green
Write-Host " Files processed : $total" -ForegroundColor Green
Write-Host " Added           : $added" -ForegroundColor Green
Write-Host " Updated         : $updated" -ForegroundColor Green
Write-Host " Skipped         : $skipped" -ForegroundColor Green
Write-Host " Preview mode    : $Preview" -ForegroundColor Green
Write-Host " Remove mode     : $Remove" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green