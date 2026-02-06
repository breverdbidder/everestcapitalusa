# ============================================
# watch-and-upload.ps1
# Auto-uploads when files are added to project folders
# Run in PowerShell ISE: File → Open → click ▶ Run
# ============================================

$repoPath = "$env:USERPROFILE\Desktop\everestcapitalusa"
$watchPath = "$repoPath\projects"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Watching $watchPath for new files..." -ForegroundColor Cyan
Write-Host "  Drop photos/PDFs into any project folder." -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop." -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $watchPath
$watcher.IncludeSubdirectories = $true
$watcher.Filter = "*.*"
$watcher.EnableRaisingEvents = $true

$timer = New-Object System.Timers.Timer
$timer.Interval = 5000
$timer.AutoReset = $false

$action = {
    Set-Location $repoPath
    git add .
    $status = git status --porcelain
    if ($status) {
        $fileCount = ($status | Measure-Object).Count
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        git commit -m "Auto-upload $fileCount files - $timestamp"
        git push origin main
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Uploaded $fileCount files" -ForegroundColor Green
    }
}

Register-ObjectEvent $timer "Elapsed" -Action $action | Out-Null

$onChange = {
    $timer.Stop()
    $timer.Start()
    $name = $Event.SourceEventArgs.Name
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Detected: $name" -ForegroundColor Gray
}

Register-ObjectEvent $watcher "Created" -Action $onChange | Out-Null
Register-ObjectEvent $watcher "Changed" -Action $onChange | Out-Null

while ($true) { Start-Sleep -Seconds 1 }
