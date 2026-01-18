$src = Join-Path (Get-Location) "src"

$processed = 0
$updated   = 0
$skipped   = 0

Get-ChildItem $src -Recurse -File -Include *.ts, *.html, *.css | ForEach-Object {

    $processed++

    $fullPath = $_.FullName
    $relativePath = $fullPath.Substring($src.Length + 1)
    $relativePath = "src\" + $relativePath

    Write-Host "Processing:" $relativePath -ForegroundColor Cyan

    $firstLine = Get-Content $fullPath -TotalCount 1

    if ($firstLine -and $firstLine.Contains($relativePath)) {
        Write-Host "  Skipped (already has path comment)" -ForegroundColor DarkYellow
        $skipped++
        return
    }

    switch ($_.Extension) {
        ".ts"   { $comment = "// $relativePath" }
        ".html" { $comment = "<!-- $relativePath -->" }
        ".css"  { $comment = "/* $relativePath */" }
    }

    $content = Get-Content $fullPath
    $newContent = @($comment, "") + $content

    Set-Content -Path $fullPath -Value $newContent

    Write-Host "  Updated" -ForegroundColor Green
    $updated++
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Processed:" $processed
Write-Host "Updated  :" $updated
Write-Host "Skipped  :" $skipped
