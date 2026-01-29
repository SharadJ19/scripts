# ================================
# Clean state acknowledgement
# ================================
Clear-Host
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host " Angular SRC Exporter for LLMs" -ForegroundColor Cyan
Write-Host " Clean state initialized" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# ================================
# Config
# ================================
$srcPath = "src"
$outputFile = "angular-src-export.txt"

# File types to include (edit if needed)
$extensions = @(
    "*.ts",
    "*.html",
    "*.scss",
    "*.css",
    "*.json"
)

# ================================
# Validation
# ================================
if (!(Test-Path $srcPath)) {
    Write-Host "ERROR: src folder not found!" -ForegroundColor Red
    exit
}

# ================================
# Collect files
# ================================
$files = Get-ChildItem -Path $srcPath -Recurse -File -Include $extensions
$total = $files.Count

if ($total -eq 0) {
    Write-Host "No files found in src folder." -ForegroundColor Yellow
    exit
}

Write-Host "Found $total files. Processing..." -ForegroundColor Yellow
Write-Host ""

# ================================
# Process files with loading visualization
# ================================
$counter = 0
$builder = New-Object System.Text.StringBuilder

foreach ($file in $files) {
    $counter++

    # Progress bar
    $percent = [int](($counter / $total) * 100)
    Write-Progress -Activity "Exporting src files" `
                   -Status "$counter of $total ($percent%)" `
                   -PercentComplete $percent

    # Relative path (to src)
    $relativePath = $file.FullName.Substring((Resolve-Path $srcPath).Path.Length + 1)

    # Comment header
    $builder.AppendLine("====================================") | Out-Null
    $builder.AppendLine("// PATH: src/$relativePath") | Out-Null
    $builder.AppendLine("====================================") | Out-Null

    # File content
    $content = Get-Content $file.FullName -Raw
    $builder.AppendLine($content) | Out-Null
    $builder.AppendLine("`n") | Out-Null
}

# ================================
# Output
# ================================
$finalText = $builder.ToString()

# Save to file
$finalText | Set-Content $outputFile -Encoding UTF8

# Copy to clipboard
Set-Clipboard -Value $finalText

# ================================
# Done
# ================================
Write-Progress -Activity "Exporting src files" -Completed
Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host " Export completed successfully" -ForegroundColor Green
Write-Host " Output file: $outputFile" -ForegroundColor Green
Write-Host " Content copied to clipboard" -ForegroundColor Green
Write-Host " Ready to paste into ChatGPT / LLM" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
