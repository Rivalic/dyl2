# Quick Setup Guide - GitHub Actions Build

Since you're on Windows and don't have access to a Mac for compiling the dylib, follow these steps to build the IPA automatically using GitHub Actions:

## Step 1: Create GitHub Repository

1. **Go to GitHub** (https://github.com)
2. **Sign in** to your account
3. **Click "New repository"** (top right, + icon)
4. **Repository settings:**
   - Name: `swiggy-device-rotation` (or any name you prefer)
   - Description: "Swiggy iOS app with device ID rotation"
   - **⚠️ IMPORTANT**: Set to **Private** (contains decrypted app)
   - Don't initialize with README (we already have one)

5. **Click "Create repository"**

## Step 2: Push Code to GitHub

Open PowerShell in this directory and run:

```powershell
# Initialize git repository
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial commit: Swiggy with device rotation dylib"

# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR_USERNAME/swiggy-device-rotation.git

# Rename branch to main
git branch -M main

# Push to GitHub
git push -u origin main
```

**Replace `YOUR_USERNAME`** with your actual GitHub username in the command above!

## Step 3: Trigger GitHub Actions Build

1. **Go to your repository** on GitHub
2. **Click the "Actions" tab** at the top
3. You'll see the workflow: **"Build Swiggy IPA with Device Rotation"**
4. **Click on the workflow**
5. **Click "Run workflow"** button (right side)
6. Select `main` branch
7. **Click "Run workflow"** (green button)

## Step 4: Wait for Build to Complete

The build process will:
- ✅ Setup Theos on macOS runner
- ✅ Install dependencies (ldid, insert_dylib)
- ✅ Compile `DeviceRotation.dylib` for iOS arm64
- ✅ Inject dylib into Swiggy binary
- ✅ Re-sign the app
- ✅ Build final IPA

**Estimated time:** 5-10 minutes

## Step 5: Download the IPA

Once the workflow completes successfully:

1. **Click on the completed workflow run** (green checkmark ✅)
2. **Scroll down to "Artifacts"** section
3. **Click to download**: `Swiggy-DeviceRotation-IPA`
4. **Extract the ZIP** - inside you'll find: `Swiggy-DeviceRotation.ipa`

## Step 6: Install on iPhone

### Option A: AltStore (Free)

1. Install AltStore from https://altstore.io
2. Open AltStore on iPhone
3. Tap "+" and select the IPA
4. Sign with your Apple ID
5. Wait for installation

### Option B: Sideloadly (Easier)

1. Download from https://sideloadly.io
2. Connect iPhone via USB
3. Drag IPA into Sideloadly
4. Enter Apple ID
5. Click "Start"

## Step 7: Use the App!

1. Open Swiggy on your iPhone
2. Wait 2 seconds - you'll see a 🔄 button (top-left)
3. Tap the button to rotate device IDs
4. Watch for green flash (success!)
5. Enjoy unlimited device rotations

---

## 🎯 Quick Commands Reference

```powershell
# One-time setup
git init
git add .
git commit -m "Initial commit: Swiggy with device rotation dylib"
git remote add origin https://github.com/YOUR_USERNAME/swiggy-device-rotation.git
git branch -M main
git push -u origin main
```

```powershell
# Future updates (after making changes)
git add .
git commit -m "Updated device rotation logic"
git push
```

---

## ⚠️ Important Notes

- **Keep repository PRIVATE** - It contains a decrypted app
- **Free GitHub account** works fine for this
- **No Mac required** - GitHub Actions does everything in the cloud
- **IPA expires in 7 days** - Re-sign with AltStore when needed

---

## 🆘 Troubleshooting

### "Permission denied" when pushing

**Solution**: Setup GitHub authentication
- Use GitHub Desktop (easier), OR
- Setup Personal Access Token: https://github.com/settings/tokens

### Build fails in GitHub Actions

**Check the logs**:
1. Go to Actions tab
2. Click failed workflow
3. Expand failed step
4. Read error message

Common fixes:
- Ensure all files were pushed correctly
- Check if `swiggy-extracted/` folder exists
- Verify Makefile syntax

### Can't find artifact download

**Location**: 
- Workflow run page → Scroll to bottom → "Artifacts" section
- Must wait for workflow to complete (green ✅)

---

## 🎉 That's It!

You now have a fully automated build system for creating Swiggy IPAs with device rotation, all from Windows!

**No Mac. No Jailbreak. Just GitHub Actions.** 🚀
