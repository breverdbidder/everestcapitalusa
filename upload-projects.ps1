# ============================================
# upload-projects.ps1
# One-click upload of all project files to GitHub
# ============================================

$repoPath = "$env:USERPROFILE\Desktopverestcapitalusa"

Set-Location $repoPath
git pull origin main

git add .

$status = git status --porcelain
if ($status) {
    $fileCount = ($status | Measure-Object).Count
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $message = "Upload $fileCount files - $timestamp"
    
    git commit -m $message
    git push origin main
    
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  SUCCESS: $fileCount files uploaded to GitHub" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next step: Tell Claude 'files uploaded' to deploy to the live site." -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "No new files to upload. Add photos/PDFs to the projects/ folders first." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
