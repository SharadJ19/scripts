# ==========================================================
# Angular SRC Exporter for LLMs (Clipboard-Only, Beast Mode)
# ==========================================================

Clear-Host
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host " Angular SRC Exporter for LLMs" -ForegroundColor Cyan
Write-Host " Clipboard-only | Angular-ordered | Verbose CLI" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# ================================
# CONFIG (EDIT FREELY)
# ================================

$SrcPath = "src"

# Extensions to include
$IncludeExtensions = @(
    "*.ts",
    "*.html",
    "*.css"
)

# Exclude folders (Angular + tooling noise)
$ExcludeFolders = @(
    "node_modules",
    "dist",
    ".angular",
    ".git",
    "assets"
)

# Exclude specific files
$ExcludeFiles = @(
    "main.ts",
    "polyfills.ts"
)

# Logging controls
$ShowFileAddedLogs = $true
$ShowSectionSummaries = $true

# Header formatting
$HeaderDivider = "===================================="

# ================================
# VALIDATION
# ================================

if (!(Test-Path $SrcPath)) {
    Write-Host "ERROR: src folder not found." -ForegroundColor Red
    return
}

Write-Host "SRC path validated: $SrcPath" -ForegroundColor Green
Write-Host ""

# ================================
# FILE COLLECTION
# ================================

Write-Host "Scanning files..." -ForegroundColor Yellow

$allFiles = Get-ChildItem -Path $SrcPath -Recurse -File -Include $IncludeExtensions |
    Where-Object {
        $path = $_.FullName
        ($ExcludeFolders | ForEach-Object { $path -notmatch "\\$_\\" }) -and
        ($ExcludeFiles -notcontains $_.Name)
    }

if ($allFiles.Count -eq 0) {
    Write-Host "No matching files found." -ForegroundColor Yellow
    return
}

Write-Host "Files discovered: $($allFiles.Count)" -ForegroundColor Green
Write-Host ""

# ================================
# ANGULAR-AWARE ORDERING
# ================================

function Get-AngularPriority {
    param ($FilePath)

    switch -Regex ($FilePath) {
        "app\.module\.ts"          { return 1 }
        "\.module\.ts$"            { return 2 }
        "\.service\.ts$"           { return 3 }
        "\.(guard|interceptor)\.ts$" { return 4 }
        "\.component\.ts$"         { return 5 }
        "\.component\.html$"       { return 6 }
        "\.component\.css$"        { return 7 }
        default                    { return 99 }
    }
}

$orderedFiles = $allFiles |
    Sort-Object @{ Expression = { Get-AngularPriority $_.FullName } }, FullName

# ================================
# EXPORT TO CLIPBOARD
# ================================

$builder = New-Object System.Text.StringBuilder
$total = $orderedFiles.Count
$counter = 0

Write-Host "Exporting files to clipboard..." -ForegroundColor Yellow
Write-Host ""

foreach ($file in $orderedFiles) {
    $counter++

    $percent = [int](($counter / $total) * 100)
    Write-Progress `
        -Activity "Angular SRC Export" `
        -Status "$counter of $total ($percent%)" `
        -PercentComplete $percent

    $relativePath = $file.FullName.Substring(
        (Resolve-Path $SrcPath).Path.Length + 1
    )

    if ($ShowFileAddedLogs) {
        Write-Host " + src/$relativePath" -ForegroundColor DarkCyan
    }

    $builder.AppendLine($HeaderDivider) | Out-Null
    $builder.AppendLine("// PATH: src/$relativePath") | Out-Null
    $builder.AppendLine($HeaderDivider) | Out-Null
    $builder.AppendLine((Get-Content $file.FullName -Raw)) | Out-Null
    $builder.AppendLine("`n") | Out-Null
}

Write-Progress -Activity "Angular SRC Export" -Completed

# ================================
# CLIPBOARD
# ================================

$finalOutput = $builder.ToString()
Set-Clipboard -Value $finalOutput

# ================================
# FINAL ACKNOWLEDGEMENTS
# ================================

Write-Host ""
Write-Host "=================================================" -ForegroundColor Green
Write-Host " Export completed successfully" -ForegroundColor Green
Write-Host " Files exported : $total" -ForegroundColor Green
Write-Host " Destination    : Clipboard only" -ForegroundColor Green
Write-Host " Angular order  : Applied" -ForegroundColor Green
Write-Host " Ready for LLM  : Yes" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green