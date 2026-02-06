# Automated Photo & PDF Upload to GitHub

## Upload project files from your desktop folders directly to GitHub — no manual drag-and-drop needed.

**Repository:** `breverdbidder/everestcapitalusa`
**Target folders:** `projects/01/` through `projects/10/`
**Your system:** Windows + PowerShell

---

## One-Time Setup (5 minutes)

### Step 1: Install Git

Open PowerShell **as Administrator** and run:

```powershell
winget install Git.Git
```

Close and reopen PowerShell after installation. Verify it worked:

```powershell
git --version
```

You should see something like `git version 2.43.0.windows.1`.

### Step 2: Configure Git with Your Identity

```powershell
git config --global user.name "Ariel Shapira"
git config --global user.email "ariel@everestcapitalusa.com"
```

### Step 3: Clone the Repository to Your Desktop

```powershell
cd ~/Desktop
git clone https://github.com/breverdbidder/everestcapitalusa.git
cd everestcapitalusa
```

Git will ask for authentication. Use:
- **Username:** `breverdbidder`
- **Password:** Your GitHub Personal Access Token (PAT)

> **Tip:** To avoid entering the PAT every time:
> ```powershell
> git config --global credential.helper store
> ```
> This saves credentials after the first successful login.

### Step 4: Verify the Folder Structure

```powershell
dir projects
```

You should see folders `01` through `10`. Each is ready for your files.

---

## Uploading Files (The Daily Workflow)

### Option A: Simple Manual Upload (30 seconds per project)

**1. Copy your files into the project folder:**

Open File Explorer and drag your photos and PDFs into the appropriate folder:

```
Desktop\everestcapitalusa\projects\01\   ← drop photos + PDFs here
Desktop\everestcapitalusa\projects\02\   ← drop photos + PDFs here
...
```

Name files anything you want: `front.jpg`, `IMG_4521.jpg`, `kitchen.png`, `floorplan.pdf` — all work.

**2. Open PowerShell and push:**

```powershell
cd ~/Desktop/everestcapitalusa
git add .
git commit -m "Add photos and drawings for Project 01"
git push
```

Done. Files are on GitHub. Then tell Claude "files uploaded" and I'll deploy them to the live site.

---

### Option B: One-Click Automated Script (Recommended)

Create this script once, then double-click it whenever you add new files.

**1. Create the script:**

Open Notepad and paste this:

```powershell
# ============================================
# upload-projects.ps1
# One-click upload of all project files to GitHub
# ============================================

$repoPath = "$env:USERPROFILE\Desktop\everestcapitalusa"

# Navigate to repo
Set-Location $repoPath

# Pull latest changes first (avoid conflicts)
git pull origin main

# Stage all new/modified files
git add .

# Check if there are changes to commit
$status = git status --porcelain
if ($status) {
    # Count new files
    $fileCount = ($status | Measure-Object).Count
    
    # Create descriptive commit message
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $message = "Upload $fileCount files - $timestamp"
    
    # Commit and push
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
```

**2. Save it:**

Save as: `Desktop\everestcapitalusa\upload-projects.ps1`

**3. Create a shortcut for one-click execution:**

Right-click on your Desktop → New → Shortcut. Paste this as the location:

```
powershell.exe -ExecutionPolicy Bypass -File "%USERPROFILE%\Desktop\everestcapitalusa\upload-projects.ps1"
```

Name it: **"Upload Projects to GitHub"**

**4. Usage:**

1. Drop photos and PDFs into `projects/01/`, `projects/02/`, etc.
2. Double-click the **"Upload Projects to GitHub"** shortcut
3. Wait for the green SUCCESS message
4. Tell Claude "files uploaded" → I deploy to the live site

---

### Option C: Auto-Upload on File Change (Fully Automated)

This watches your project folders and uploads automatically whenever you add files.

**1. Create the watcher script:**

```powershell
# ============================================
# watch-and-upload.ps1
# Auto-uploads when files are added to project folders
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

# Debounce: wait 5 seconds after last change before uploading
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

# Keep running
while ($true) { Start-Sleep -Seconds 1 }
```

Save as: `Desktop\everestcapitalusa\watch-and-upload.ps1`

**2. Run it:**

```powershell
powershell -ExecutionPolicy Bypass -File ~/Desktop/everestcapitalusa/watch-and-upload.ps1
```

**3. How it works:**

- Watches all `projects/` subfolders
- When you drop a file, it waits 5 seconds (in case you're dropping multiple files)
- Auto-commits and pushes to GitHub
- Shows a green confirmation for each upload batch
- Keep it running in the background while you work

---

## File Organization

### Where to Put Files

```
everestcapitalusa/
  projects/
    01/
      front-exterior.jpg
      kitchen.jpg
      bathroom.png
      floorplan.pdf
    02/
      IMG_4521.jpg
      IMG_4522.jpg
      site-plan.pdf
    03/
      photo1.jpg
      photo2.jpg
      drawing.pdf
    ...
```

### Supported File Types

| Type | Extensions | Max Size | Where It Shows |
|------|-----------|----------|----------------|
| Photos | `.jpg` `.jpeg` `.png` `.webp` | 25 MB each | Gallery carousel (auto-slideshow) |
| Drawings | `.pdf` | 25 MB each | Embedded PDF viewer (inline on page) |

### Naming Rules

- **Name files anything** — `IMG_1234.jpg`, `front.jpg`, `a.png` — all work
- Photos display in **alphabetical order** in the gallery
- If you want a specific order, prefix with numbers: `01-front.jpg`, `02-kitchen.jpg`
- The first photo alphabetically becomes the **cover image**

---

## Quick Reference Card

| Task | Command |
|------|---------|
| First-time clone | `cd ~/Desktop; git clone https://github.com/breverdbidder/everestcapitalusa.git` |
| Upload all changes | `cd ~/Desktop/everestcapitalusa; git add .; git commit -m "Upload files"; git push` |
| Check what's new | `git status` |
| Pull latest from GitHub | `git pull origin main` |
| See upload history | `git log --oneline -10` |
| Undo last commit (before push) | `git reset --soft HEAD~1` |

---

## Troubleshooting

**"Permission denied" or authentication error:**
```powershell
git config --global credential.helper store
git push   # Enter username: breverdbidder, password: your PAT
```

**"Updates were rejected" (someone else pushed changes):**
```powershell
git pull --rebase origin main
git push
```

**Files too large (>100 MB):**
Compress photos before uploading, or use Git LFS:
```powershell
git lfs install
git lfs track "*.pdf"
git add .gitattributes
```

**Script won't run ("execution policy" error):**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

## After Upload: Tell Claude

Once files are on GitHub, come back to Claude and say:

> "Files uploaded for projects 01, 02, and 03"

Claude will:
1. Pull all files from the repo
2. Update the HTML with gallery images + embedded PDFs
3. Deploy to [everestcapitalusa.com](https://everestcapitalusa.com)
4. Verify everything renders correctly

Zero manual work after the upload step.
