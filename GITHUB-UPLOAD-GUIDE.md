# Automated Photo & PDF Upload to GitHub
## Using Windows PowerShell ISE

Upload project files from your desktop folders directly to GitHub — no manual drag-and-drop on the website needed.

**Repository:** `breverdbidder/everestcapitalusa`
**Target folders:** `projects/01/` through `projects/10/`
**Your tool:** Windows PowerShell ISE (built into Windows)

---

## One-Time Setup (5 minutes)

### Step 1: Install Git

1. Open **PowerShell ISE** — search "PowerShell ISE" in the Start menu, right-click → **Run as Administrator**
2. In the **blue console pane** at the bottom, type:

```powershell
winget install Git.Git
```

3. **Close and reopen PowerShell ISE** after installation
4. Verify it worked — type in the console:

```powershell
git --version
```

You should see something like `git version 2.43.0.windows.1`.

### Step 2: Configure Git with Your Identity

Type these two commands in the console pane:

```powershell
git config --global user.name "Ariel Shapira"
git config --global user.email "ariel@everestcapitalusa.com"
```

### Step 3: Save Your Credentials (So You Don't Re-Enter Every Time)

```powershell
git config --global credential.helper store
```

### Step 4: Clone the Repository to Your Desktop

```powershell
cd ~/Desktop
git clone https://github.com/breverdbidder/everestcapitalusa.git
```

Git will ask for authentication **once**:
- **Username:** `breverdbidder`
- **Password:** Your GitHub Personal Access Token (PAT)

After this, credentials are saved — you won't be asked again.

### Step 5: Verify the Folder Structure

```powershell
cd ~/Desktop/everestcapitalusa
dir projects
```

You should see folders `01` through `10`. Each is ready for your files.

---

## Uploading Files (The Daily Workflow)

### Option A: Quick Upload via ISE Console (30 seconds)

**1.** Open File Explorer and drag your photos and PDFs into the appropriate folder:

```
Desktop\everestcapitalusa\projects\01\   ← drop photos + PDFs here
Desktop\everestcapitalusa\projects\02\   ← drop photos + PDFs here
...
```

**2.** Open **PowerShell ISE** and type these 4 lines in the console pane:

```powershell
cd ~/Desktop/everestcapitalusa
git add .
git commit -m "Add photos and drawings"
git push
```

Done. Files are on GitHub.

**3.** Tell Claude **"files uploaded"** and I'll deploy them to the live site.

---

### Option B: One-Click Script in ISE (Recommended)

**1.** Open **PowerShell ISE**

**2.** Click **File → Open** and navigate to:
```
Desktop\everestcapitalusa\upload-projects.ps1
```

This script is already in the repo from the clone. It will appear in the **white script editor pane** at the top.

**3.** Click the green **▶ Run Script** button (or press **F5**)

The console pane will show:

```
============================================
  SUCCESS: 12 files uploaded to GitHub
============================================

Next step: Tell Claude 'files uploaded' to deploy to the live site.
```

That's it. One click.

**Tip:** Pin PowerShell ISE to your taskbar for fast access. Open ISE → the script is already loaded from last time → hit F5 → done.

---

### Option C: Auto-Upload Watcher (Fully Hands-Free)

This watches your project folders and uploads automatically whenever you drop files in.

**1.** Open **PowerShell ISE**

**2.** Click **File → Open** and navigate to:
```
Desktop\everestcapitalusa\watch-and-upload.ps1
```

**3.** Click the green **▶ Run Script** button (or press **F5**)

The console will show:

```
============================================
  Watching for new files...
  Drop photos/PDFs into any project folder.
  Press Ctrl+C to stop.
============================================
```

**4.** Now just drag and drop files into any `projects/` folder in File Explorer. The script detects new files, waits 5 seconds (in case you're dropping multiple), then auto-commits and pushes:

```
[14:32:05] Detected: 01/front-exterior.jpg
[14:32:06] Detected: 01/kitchen.jpg
[14:32:11] Uploaded 2 files ✅
```

**5.** Leave the ISE window running in the background while you work. Press **Ctrl+C** to stop.

---

## Where to Put Your Files

### Folder Structure

```
Desktop\
  everestcapitalusa\
    projects\
      01\
        front-exterior.jpg
        kitchen.jpg
        bathroom.png
        floorplan.pdf
      02\
        IMG_4521.jpg
        IMG_4522.jpg
        site-plan.pdf
      03\
        photo1.jpg
        drawing.pdf
      ...
```

### Supported File Types

| Type | Extensions | Max Size | How It Displays on the Website |
|------|-----------|----------|-------------------------------|
| Photos | `.jpg` `.jpeg` `.png` `.webp` | 25 MB each | Auto-slideshow gallery carousel |
| Drawings | `.pdf` | 25 MB each | Embedded PDF viewer (scrollable, inline) |

### Naming Rules

- **Name files anything** — `IMG_1234.jpg`, `front.jpg`, `a.png` — all work
- Photos display in **alphabetical order** in the gallery
- Want a specific order? Prefix with numbers: `01-front.jpg`, `02-kitchen.jpg`, `03-bathroom.jpg`
- The first photo alphabetically becomes the **cover image** for that project card

---

## PowerShell ISE Quick Reference

| Action | How |
|--------|-----|
| Open ISE | Start menu → search "PowerShell ISE" |
| Run as Admin | Right-click ISE → "Run as Administrator" |
| Open a script | File → Open → select `.ps1` file |
| Run a script | Click green **▶** button or press **F5** |
| Stop a running script | Press **Ctrl+C** in the console pane |
| Type commands manually | Click in the **blue console pane** at the bottom |
| Clear the console | Type `cls` or `Clear-Host` |

---

## Git Commands Quick Reference

Type these in the **ISE console pane** (bottom):

| Task | Command |
|------|---------|
| Go to repo folder | `cd ~/Desktop/everestcapitalusa` |
| Upload all changes | `git add .; git commit -m "Upload files"; git push` |
| Check what's new/changed | `git status` |
| Pull latest from GitHub | `git pull origin main` |
| See upload history | `git log --oneline -10` |
| Undo last commit (before push) | `git reset --soft HEAD~1` |

---

## Troubleshooting

### "Running scripts is disabled on this system"

Type in the ISE console:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```
Then try running the script again.

### Authentication error / "Permission denied"

```powershell
git config --global credential.helper store
git push
```
Enter username `breverdbidder` and your PAT as the password. It saves after the first time.

### "Updates were rejected" (conflict with GitHub)

```powershell
git pull --rebase origin main
git push
```

### Files too large (over 100 MB)

Compress large photos before uploading, or install Git LFS:
```powershell
git lfs install
git lfs track "*.pdf"
git add .gitattributes
git add .
git commit -m "Enable LFS for large PDFs"
git push
```

### ISE won't open / missing

PowerShell ISE is included in Windows 10. If missing:
1. Open Settings → Apps → Optional Features
2. Click "Add a feature"
3. Search "Windows PowerShell ISE" → Install

---

## Complete Workflow Summary

```
┌─────────────────────────────────────────────┐
│  1. Drop files into projects/01/, 02/, etc. │
│     (File Explorer — drag and drop)         │
│                    ↓                        │
│  2. Open PowerShell ISE                     │
│     File → Open → upload-projects.ps1       │
│     Click ▶ Run (or press F5)               │
│                    ↓                        │
│  3. See "SUCCESS" in console                │
│                    ↓                        │
│  4. Tell Claude "files uploaded"            │
│     Claude deploys to live site             │
│                    ↓                        │
│  5. Live at everestcapitalusa.com ✅         │
└─────────────────────────────────────────────┘
```

---

## After Upload: Tell Claude

Once files are on GitHub, come back to Claude and say:

> "Files uploaded for projects 01, 02, and 03"

Claude will:
1. Pull all files from the repo
2. Update the HTML with gallery images and embedded PDF viewers
3. Deploy to [everestcapitalusa.com](https://everestcapitalusa.com)
4. Verify everything renders correctly

Zero manual work after the upload step.
