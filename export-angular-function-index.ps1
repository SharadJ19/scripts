# ==========================================================
# Angular Function Indexer
# Lifecycle + Constructor tagging
# Progress + Function statistics
# Clipboard Output
# ==========================================================

Clear-Host
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " Angular Function Indexer" -ForegroundColor Cyan
Write-Host " Lifecycle tagging | Progress | Stats" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# ================================
# CONFIG
# ================================

$SrcPath = "src"

$ExcludeFolders = @(
    "node_modules",
    "dist",
    ".git",
    ".angular",
    "assets"
)

$InvalidNames = @(
    "if","for","while","switch","catch","map","tap",
    "pipe","subscribe","catchError","debounceTime",
    "distinctUntilChanged","takeUntil","setTimeout",
    "setInterval","filter","reduce"
)

$LifecycleHooks = @(
    "ngOnChanges",
    "ngOnInit",
    "ngDoCheck",
    "ngAfterContentInit",
    "ngAfterContentChecked",
    "ngAfterViewInit",
    "ngAfterViewChecked",
    "ngOnDestroy"
)

# ================================
# VALIDATION
# ================================

if (!(Test-Path $SrcPath)) {
    Write-Host "ERROR: src folder not found." -ForegroundColor Red
    return
}

Write-Host "Scanning TypeScript files..." -ForegroundColor Yellow

# ================================
# FILE COLLECTION
# ================================

$files = Get-ChildItem -Path $SrcPath -Recurse -Filter *.ts |
Where-Object {
    $path = $_.FullName
    ($ExcludeFolders | ForEach-Object { $path -notmatch "\\$_\\" })
}

$totalFiles = $files.Count
$totalFunctions = 0

Write-Host "Files discovered: $totalFiles" -ForegroundColor Green
Write-Host ""

# ================================
# SCAN FILES
# ================================

$builder = New-Object System.Text.StringBuilder
$fileIndex = 0

foreach ($file in $files) {

    $fileIndex++

    $percent = [int](($fileIndex / $totalFiles) * 100)

    Write-Progress `
        -Activity "Scanning Angular Functions" `
        -Status "$fileIndex of $totalFiles ($percent%)" `
        -PercentComplete $percent

    $relativePath = $file.FullName.Substring(
        (Resolve-Path $SrcPath).Path.Length + 1
    )

    $lines = Get-Content $file.FullName
    $found = $false
    $fileFunctionCount = 0

    for ($i = 0; $i -lt $lines.Length; $i++) {

        $line = $lines[$i].Trim()

        if ($line -match '^(public|private|protected)?\s*(static\s*)?(async\s*)?([A-Za-z_][A-Za-z0-9_]*)\s*\(') {
            $name = $Matches[4]
        }
        elseif ($line -match '^(const|let|var)\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(async\s*)?\(') {
            $name = $Matches[2]
        }
        elseif ($line -match '^function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(') {
            $name = $Matches[1]
        }
        else {
            continue
        }

        if ($InvalidNames -contains $name) {
            continue
        }

        $tag = ""

        if ($name -eq "constructor") {
            $tag = " [CTOR]"
        }
        elseif ($LifecycleHooks -contains $name) {
            $tag = " [LIFE]"
        }

        if (!$found) {
            $builder.AppendLine("src/$relativePath") | Out-Null
            $found = $true
        }

        $lineNumber = $i + 1
        $builder.AppendLine("  $lineNumber  $name()$tag") | Out-Null

        $fileFunctionCount++
        $totalFunctions++
    }

    if ($found) {
        $builder.AppendLine("") | Out-Null
        Write-Host (" + src/$relativePath  ->  $fileFunctionCount functions") -ForegroundColor DarkCyan
    }
}

Write-Progress -Activity "Scanning Angular Functions" -Completed

# ================================
# CLIPBOARD
# ================================

$output = $builder.ToString()

if ([string]::IsNullOrWhiteSpace($output)) {
    Write-Host "No functions detected." -ForegroundColor Yellow
    return
}

Set-Clipboard -Value $output

# ================================
# FINAL SUMMARY
# ================================

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host " Function index copied to clipboard" -ForegroundColor Green
Write-Host " Files scanned      : $totalFiles" -ForegroundColor Green
Write-Host " Total functions    : $totalFunctions" -ForegroundColor Green
Write-Host " Lifecycle hints    : Enabled" -ForegroundColor Green
Write-Host " Destination        : Clipboard" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green